-- =====================================================================
-- Flattened search view: one row per player, with team/league names
-- and an aggregated trait_id array, so the client can filter everything
-- in a single query (see player_repository.dart -> search()).
-- =====================================================================

create or replace view players_search_view as
select
  p.id,
  p.full_name,
  p.common_name,
  p.team_id,
  t.name as team_name,
  t.league_id,
  l.name as league_name,
  p.nationality,
  p.age,
  p.preferred_foot,
  p.position_primary,
  p.position_group,
  p.positions_secondary,
  p.overall_rating,
  p.potential_rating,
  p.initial_overall_rating,
  p.initial_potential_rating,
  p.max_potential_projection,
  p.photo_url,
  p.has_real_face,
  p.market_value,
  p.wage,
  p.is_wonderkid,
  p.is_hidden_gem,
  coalesce(
    (select array_agg(pt.trait_id) from player_traits pt where pt.player_id = p.id),
    array[]::uuid[]
  ) as trait_ids,
  coalesce(
    (select array_agg(tr.name) from player_traits pt
       join traits tr on tr.id = pt.trait_id
       where pt.player_id = p.id),
    array[]::text[]
  ) as traits,
  ps.pace, ps.shooting, ps.passing, ps.dribbling, ps.defending, ps.physical
from players p
left join teams t on t.id = p.team_id
left join leagues l on l.id = t.league_id
left join player_stats ps on ps.player_id = p.id;

-- Index support: the view inherits indexes from base tables for most
-- filters; trait containment benefits from a GIN index on the array.
-- (Materialize this view instead of a plain view if player count grows
-- past ~50k rows and query latency becomes noticeable — refresh on a
-- schedule or on player table change via trigger.)
