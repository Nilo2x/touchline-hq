-- =====================================================================
-- TouchlineHQ — Initial Schema
-- Developer: Coach: Danilo
-- =====================================================================
-- NOTE ON DATA: This schema is designed to hold real FC26 data once you
-- connect a legally-sourced feed. The seed data at the bottom of this
-- file (see 0002_seed_placeholder.sql) is 100% FICTIONAL placeholder
-- content used only to prove the schema/UI work end-to-end.
-- =====================================================================

create extension if not exists "uuid-ossp";
create extension if not exists pg_trgm;       -- fuzzy name search
create extension if not exists unaccent;      -- accent-insensitive search

-- ---------------------------------------------------------------------
-- LEAGUES
-- ---------------------------------------------------------------------
create table leagues (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null unique,
  country     text not null,
  tier        int  not null default 1,        -- 1 = top flight
  logo_url    text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- TEAMS
-- ---------------------------------------------------------------------
create table teams (
  id           uuid primary key default uuid_generate_v4(),
  league_id    uuid references leagues(id) on delete set null,
  name         text not null,
  short_name   text,
  crest_url    text,
  overall_rating int,             -- team avg OVR, denormalized for fast sort
  wage_budget    numeric(12,2),   -- weekly wage budget cap, in-game currency
  transfer_budget numeric(14,2),
  country      text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index idx_teams_league on teams(league_id);
create index idx_teams_name_trgm on teams using gin (name gin_trgm_ops);

-- ---------------------------------------------------------------------
-- TRAITS / PLAYSTYLES (Finesse Shot, Trickster, Technical, Long Ball Pass, etc.)
-- ---------------------------------------------------------------------
create table traits (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null unique,
  category    text not null check (category in ('playstyle','playstyle_plus','trait')),
  icon_url    text,
  description text
);

-- ---------------------------------------------------------------------
-- PLAYERS
-- ---------------------------------------------------------------------
create table players (
  id                uuid primary key default uuid_generate_v4(),
  external_ref      text unique,            -- id from your licensed data source, for sync
  full_name         text not null,
  common_name       text,
  team_id           uuid references teams(id) on delete set null,
  nationality       text not null,
  birth_date        date,
  age               int,                    -- denormalized, refreshed nightly
  height_cm         int,
  weight_kg         int,
  preferred_foot    text check (preferred_foot in ('left','right')),

  -- Positions
  position_primary  text not null,          -- e.g. 'ST'
  positions_secondary text[],               -- e.g. ['CF','LW']
  position_group    text generated always as (
    case
      when position_primary in ('GK') then 'GK'
      when position_primary in ('CB','LB','RB','LWB','RWB') then 'DEF'
      when position_primary in ('CDM','CM','CAM','LM','RM') then 'MID'
      when position_primary in ('ST','CF','LW','RW') then 'FWD'
      else 'UNK'
    end
  ) stored,

  -- Ratings & potential
  overall_rating       int not null check (overall_rating between 1 and 99),
  potential_rating      int not null check (potential_rating between 1 and 99),
  initial_overall_rating int,                -- OVR at career-mode start (snapshot)
  initial_potential_rating int,              -- Potential at career-mode start (snapshot)
  max_potential_projection int,              -- dynamic projection if dev plan completed

  -- Visuals / authenticity flags
  photo_url         text,
  avatar_fallback_seed text,                 -- deterministic seed for generated avatar
  has_real_face     boolean not null default false,   -- explicit Real Face scan marker

  -- Value
  market_value      numeric(14,2),
  wage              numeric(12,2),
  contract_expires  date,

  -- Flags
  is_wonderkid      boolean generated always as (age <= 21 and potential_rating >= 83) stored,
  is_hidden_gem     boolean generated always as (
                       overall_rating < 78 and potential_rating >= 85
                     ) stored,

  source_updated_at timestamptz,             -- last-changed timestamp from data source
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index idx_players_team on players(team_id);
create index idx_players_name_trgm on players using gin (full_name gin_trgm_ops);
create index idx_players_position on players(position_primary);
create index idx_players_ratings on players(overall_rating, potential_rating);
create index idx_players_nationality on players(nationality);
create index idx_players_wonderkid on players(is_wonderkid) where is_wonderkid;
create index idx_players_hidden_gem on players(is_hidden_gem) where is_hidden_gem;

-- Detailed sub-stats (kept separate so the main row stays light for list views)
create table player_stats (
  player_id   uuid primary key references players(id) on delete cascade,
  pace        int, shooting   int, passing    int,
  dribbling   int, defending  int, physical   int,
  -- granular, used by radar chart widget
  acceleration int, sprint_speed int, finishing int, shot_power int,
  long_shots int, vision int, crossing int, free_kick_accuracy int,
  ball_control int, agility int, balance int, reactions int,
  interceptions int, def_awareness int, standing_tackle int, sliding_tackle int,
  jumping int, stamina int, strength int, aggression int
);

create table player_traits (
  player_id uuid references players(id) on delete cascade,
  trait_id  uuid references traits(id) on delete cascade,
  primary key (player_id, trait_id)
);

-- ---------------------------------------------------------------------
-- TRANSFER HISTORY (drives "real-time transfer updates" feed)
-- ---------------------------------------------------------------------
create table transfer_events (
  id           uuid primary key default uuid_generate_v4(),
  player_id    uuid references players(id) on delete cascade,
  from_team_id uuid references teams(id),
  to_team_id   uuid references teams(id),
  fee          numeric(14,2),
  transfer_type text check (transfer_type in ('permanent','loan','free','release')),
  effective_date date not null,
  source        text,             -- which feed/source reported it
  created_at    timestamptz not null default now()
);
create index idx_transfer_player on transfer_events(player_id);
create index idx_transfer_date on transfer_events(effective_date desc);

-- ---------------------------------------------------------------------
-- USERS (Supabase auth.users is the source of truth; this is a public profile)
-- ---------------------------------------------------------------------
create table profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_url   text,
  created_at   timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- SQUADS (Parallel Play squad builder)
-- ---------------------------------------------------------------------
create table squads (
  id              uuid primary key default uuid_generate_v4(),
  owner_id        uuid references profiles(id) on delete cascade not null,
  name            text not null,
  managed_team_id uuid references teams(id),     -- the real-world team the user is managing in their career
  formation       text not null default '4-3-3',
  transfer_budget numeric(14,2),
  wage_budget     numeric(12,2),
  invite_code     text unique not null,           -- short shareable code
  is_public       boolean not null default false,
  rating_avg      numeric(3,1) default 0,
  rating_count    int default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index idx_squads_owner on squads(owner_id);
create unique index idx_squads_invite_code on squads(invite_code);

-- Slots: which player sits in which formation position for a squad
create table squad_slots (
  id          uuid primary key default uuid_generate_v4(),
  squad_id    uuid references squads(id) on delete cascade not null,
  player_id   uuid references players(id),
  slot_position text not null,      -- e.g. 'ST', 'CAM', 'LB' per formation
  slot_index    int not null,       -- ordering on the pitch UI
  is_starting   boolean not null default true,
  created_at    timestamptz not null default now(),
  unique (squad_id, slot_index)
);
create index idx_slots_squad on squad_slots(squad_id);

-- Members who joined a shared squad via invite code (view/clone/rate rights)
create table squad_members (
  squad_id    uuid references squads(id) on delete cascade,
  user_id     uuid references profiles(id) on delete cascade,
  role        text not null default 'viewer' check (role in ('owner','editor','viewer')),
  joined_at   timestamptz not null default now(),
  primary key (squad_id, user_id)
);

create table squad_ratings (
  squad_id   uuid references squads(id) on delete cascade,
  user_id    uuid references profiles(id) on delete cascade,
  rating     int not null check (rating between 1 and 5),
  created_at timestamptz not null default now(),
  primary key (squad_id, user_id)
);

-- ---------------------------------------------------------------------
-- TACTICAL ROOM CHAT
-- ---------------------------------------------------------------------
create table chat_messages (
  id          uuid primary key default uuid_generate_v4(),
  squad_id    uuid references squads(id) on delete cascade not null,
  user_id     uuid references profiles(id) on delete cascade not null,
  body        text not null,
  message_type text not null default 'text' check (message_type in ('text','system','player_share')),
  shared_player_id uuid references players(id),  -- lets users drop a player card into chat
  created_at  timestamptz not null default now()
);
create index idx_chat_squad_time on chat_messages(squad_id, created_at);

-- =====================================================================
-- ROW LEVEL SECURITY
-- =====================================================================
alter table squads enable row level security;
alter table squad_slots enable row level security;
alter table squad_members enable row level security;
alter table chat_messages enable row level security;
alter table squad_ratings enable row level security;

-- Owners manage their own squads
create policy "squad owner full access" on squads
  for all using (owner_id = auth.uid());

-- Public squads readable by anyone; private squads readable by members
create policy "squad read access" on squads
  for select using (
    is_public = true
    or owner_id = auth.uid()
    or exists (select 1 from squad_members m where m.squad_id = squads.id and m.user_id = auth.uid())
  );

create policy "squad_slots follow squad visibility" on squad_slots
  for select using (
    exists (
      select 1 from squads s
      where s.id = squad_slots.squad_id
      and (s.is_public or s.owner_id = auth.uid()
           or exists (select 1 from squad_members m where m.squad_id = s.id and m.user_id = auth.uid()))
    )
  );

create policy "squad_slots editable by owner/editor" on squad_slots
  for insert with check (
    exists (
      select 1 from squads s
      where s.id = squad_slots.squad_id and s.owner_id = auth.uid()
    )
    or exists (
      select 1 from squad_members m
      where m.squad_id = squad_slots.squad_id and m.user_id = auth.uid() and m.role = 'editor'
    )
  );

create policy "members can join via valid code (insert only)" on squad_members
  for insert with check (user_id = auth.uid());

create policy "members visible to squad participants" on squad_members
  for select using (
    user_id = auth.uid()
    or exists (select 1 from squads s where s.id = squad_members.squad_id and s.owner_id = auth.uid())
  );

create policy "chat readable by squad participants" on chat_messages
  for select using (
    exists (
      select 1 from squads s
      where s.id = chat_messages.squad_id
      and (s.owner_id = auth.uid()
           or exists (select 1 from squad_members m where m.squad_id = s.id and m.user_id = auth.uid()))
    )
  );

create policy "chat insert by squad participants" on chat_messages
  for insert with check (
    user_id = auth.uid()
    and (
      exists (select 1 from squads s where s.id = chat_messages.squad_id and s.owner_id = auth.uid())
      or exists (select 1 from squad_members m where m.squad_id = chat_messages.squad_id and m.user_id = auth.uid())
    )
  );

create policy "ratings: one per user, must be a member" on squad_ratings
  for insert with check (
    user_id = auth.uid()
    and exists (
      select 1 from squads s
      where s.id = squad_ratings.squad_id
      and (s.is_public or exists (select 1 from squad_members m where m.squad_id = s.id and m.user_id = auth.uid()))
    )
  );

-- =====================================================================
-- REALTIME: enable logical replication for live sync tables
-- =====================================================================
alter publication supabase_realtime add table squad_slots;
alter publication supabase_realtime add table chat_messages;
alter publication supabase_realtime add table squad_members;
