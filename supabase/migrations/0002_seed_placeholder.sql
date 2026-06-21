-- =====================================================================
-- PLACEHOLDER SEED DATA — 100% FICTIONAL
-- Every name, club, and stat below is made up for demo/testing purposes.
-- Replace by pointing player_repository.dart at a licensed data feed.
-- =====================================================================

insert into leagues (id, name, country, tier) values
  ('11111111-1111-1111-1111-111111111111', 'Fictional Premier Division', 'Demoland', 1),
  ('22222222-2222-2222-2222-222222222222', 'Fictional Liga Sur', 'Iberia (fictional)', 1);

insert into teams (id, league_id, name, short_name, overall_rating, wage_budget, transfer_budget, country) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Northgate United', 'NGU', 81, 1200000, 45000000, 'Demoland'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'Costa Vermelha CF', 'CVE', 79, 950000, 30000000, 'Iberia (fictional)');

insert into traits (id, name, category) values
  ('c1111111-1111-1111-1111-111111111111', 'Finesse Shot', 'playstyle'),
  ('c2222222-2222-2222-2222-222222222222', 'Trickster', 'playstyle'),
  ('c3333333-3333-3333-3333-333333333333', 'Technical', 'trait'),
  ('c4444444-4444-4444-4444-444444444444', 'Long Ball Pass', 'playstyle');

-- A wonderkid (fictional)
insert into players (
  id, external_ref, full_name, common_name, team_id, nationality, birth_date, age,
  preferred_foot, position_primary, positions_secondary,
  overall_rating, potential_rating, initial_overall_rating, initial_potential_rating,
  has_real_face, market_value, wage
) values (
  'd1111111-1111-1111-1111-111111111111', 'DEMO-001', 'Mateo Ferraz Silvan', 'M. Silvan',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Fictional Brazil', '2007-03-14', 19,
  'right', 'LW', array['RW','CAM'],
  76, 91, 68, 89,
  false, 28000000, 38000
);

-- A hidden gem (fictional)
insert into players (
  id, external_ref, full_name, common_name, team_id, nationality, birth_date, age,
  preferred_foot, position_primary, positions_secondary,
  overall_rating, potential_rating, initial_overall_rating, initial_potential_rating,
  has_real_face, market_value, wage
) values (
  'd2222222-2222-2222-2222-222222222222', 'DEMO-002', 'Jonas Eklund Berg', 'J. Eklund',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Fictional Sweden', '2002-11-02', 23,
  'left', 'CDM', array['CB'],
  76, 86, 73, 85,
  true, 9500000, 21000
);

insert into player_traits (player_id, trait_id) values
  ('d1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111'),
  ('d1111111-1111-1111-1111-111111111111', 'c2222222-2222-2222-2222-222222222222'),
  ('d2222222-2222-2222-2222-222222222222', 'c3333333-3333-3333-3333-333333333333');

insert into player_stats (player_id, pace, shooting, passing, dribbling, defending, physical) values
  ('d1111111-1111-1111-1111-111111111111', 92, 78, 74, 88, 35, 64),
  ('d2222222-2222-2222-2222-222222222222', 68, 52, 71, 66, 81, 79);
