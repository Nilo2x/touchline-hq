# TouchlineHQ — Architecture

Developer: Coach: Danilo

## 1. Tech Stack

| Layer | Choice | Why |
|---|---|---|
| Client framework | **Flutter 3.x (Dart)** | Single codebase → iOS + Android, best-in-class custom animation/shader support for the cyberpunk splash + glow UI, predictable 60fps on mid-range Android. |
| Backend | **Supabase** | Postgres gives relational integrity for Players/Teams/Leagues (foreign keys, joins, full-text search via `pg_trgm`/`tsvector`). Built-in Realtime (logical replication) powers live chat + live squad sync with zero custom infra. Row Level Security (RLS) handles squad-sharing permissions natively. |
| State management | **Riverpod 2.x** | Compile-safe DI, easy async data (`FutureProvider`/`StreamProvider` map cleanly onto Supabase queries + realtime streams), testable without BuildContext. |
| Realtime chat & sync | **Supabase Realtime** (Postgres CDC) + **Supabase Presence** | Tactical Room chat = `broadcast` + `postgres_changes` on `chat_messages`; presence shows who's currently viewing a shared squad. |
| Local cache | **Drift (SQLite)** | Offline-first player database browsing; large player table (18k+ rows) cached locally, synced incrementally via `updated_at` watermark. |
| Auth | **Supabase Auth** (email + anonymous guest upgrade) | Needed for invite codes to map to a real user id; anonymous auth lets users browse without forced signup. |
| Image handling | **cached_network_image** + local asset fallback | Real player photos are licensed content — see Data Sourcing note below. |

### Data Sourcing Note (read this before wiring real data)
This build ships with a **fictional placeholder dataset** (clearly fake names/photos) so every screen is fully functional out of the box. Real FC26 rosters, stats, and player photos are EA/FIFPRO/club-licensed content. To go live with real data you would point `lib/services/player_repository.dart` at your own legally-sourced feed (licensed API, your own data entry, or a CSV you control) — the sync architecture (incremental `updated_at` pulls + Supabase Realtime push) works identically regardless of where the rows come from.

## 2. Folder Structure

```
touchline_hq/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart          # ThemeData, color tokens
│   │   │   └── app_colors.dart         # Electric Blue / Navy / Cyan palette
│   │   ├── constants/
│   │   │   └── app_constants.dart      # positions, traits enum, route names
│   │   └── utils/
│   │       └── invite_code.dart        # invite code generator/validator
│   ├── models/
│   │   ├── player.dart
│   │   ├── team.dart
│   │   ├── league.dart
│   │   ├── trait.dart
│   │   ├── squad.dart
│   │   ├── squad_slot.dart
│   │   └── chat_message.dart
│   ├── services/
│   │   ├── supabase_client.dart        # singleton init
│   │   ├── player_repository.dart      # CRUD + search queries
│   │   ├── squad_repository.dart       # squad CRUD, invite codes
│   │   └── chat_repository.dart        # realtime chat stream
│   ├── providers/
│   │   ├── player_search_provider.dart # Riverpod: filter state + results
│   │   ├── squad_builder_provider.dart # Riverpod: active squad state
│   │   └── tactical_chat_provider.dart # Riverpod: StreamProvider for messages
│   ├── screens/
│   │   ├── splash/splash_screen.dart
│   │   ├── dashboard/dashboard_screen.dart
│   │   ├── search/search_screen.dart
│   │   ├── squad_builder/squad_builder_screen.dart
│   │   └── tactical_room/tactical_room_screen.dart
│   └── widgets/
│       ├── glow_button.dart
│       ├── player_card.dart
│       ├── filter_chip_bar.dart
│       └── stat_radar_chart.dart
├── supabase/
│   └── migrations/
│       └── 0001_init.sql               # full schema, Step 2
└── docs/
    └── ARCHITECTURE.md
```

## 3. Real-time Sync Flow (Squad Sharing + Tactical Room)

1. User builds a squad → `squad_repository.createSquad()` inserts into `squads`, generates a 6-char invite code (`invite_code.dart`).
2. Friend enters the code on their device → `squad_repository.joinByCode(code)` looks up the squad, inserts a row into `squad_members` (RLS checks code validity, not raw squad id, so codes can't be guessed from the squad table).
3. Both devices subscribe to `Supabase.channel('squad:<id>')`:
   - `postgres_changes` on `squad_slots` → live squad edits appear on both screens instantly.
   - `broadcast` events on the same channel → chat messages, typing indicators.
   - `presence` → shows avatars of who's currently in the Tactical Room.
4. Riverpod `StreamProvider` wraps the channel; UI rebuilds reactively — no manual polling anywhere in the app.

## 4. Why not Firebase / RN here
Firestore's document model makes the multi-tier filter system (rating range + position + nationality + trait + potential, combined) expensive — it needs either many composite indexes or client-side post-filtering. Postgres handles this natively with one indexed SQL query. React Native was considered but Flutter's `CustomPainter`/`Rive`/shader support gives a cleaner path to the cyberpunk glow/grid aesthetic without dropping frames.
