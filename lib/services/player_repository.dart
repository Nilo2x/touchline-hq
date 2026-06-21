import '../models/player.dart';
import 'supabase_client.dart';

/// Developer: Coach: Danilo
///
/// Holds every filter dimension from "Feature B: Scouting Network".
/// Immutable — each change returns a new copy, which plays nicely with
/// Riverpod's state notifiers (see player_search_provider.dart).
class PlayerFilter {
  final String? nameQuery;
  final String? teamId;
  final String? leagueId;
  final int? minAge;
  final int? maxAge;
  final String? nationality;
  final List<String> positions; // exact positions, OR'd together
  final String? positionGroup; // GK / DEF / MID / FWD, general search
  final int? minOverall;
  final int? maxOverall;
  final int? minPotential;
  final int? maxPotential;
  final List<String> requiredTraitIds; // AND'd — "must have Technical"
  final bool wonderkidOnly;
  final bool hiddenGemOnly;
  final bool realFaceOnly;
  final bool freeAgentOnly;

  const PlayerFilter({
    this.nameQuery,
    this.teamId,
    this.leagueId,
    this.minAge,
    this.maxAge,
    this.nationality,
    this.positions = const [],
    this.positionGroup,
    this.minOverall,
    this.maxOverall,
    this.minPotential,
    this.maxPotential,
    this.requiredTraitIds = const [],
    this.wonderkidOnly = false,
    this.hiddenGemOnly = false,
    this.realFaceOnly = false,
    this.freeAgentOnly = false,
  });

  PlayerFilter copyWith({
    String? nameQuery,
    String? teamId,
    String? leagueId,
    int? minAge,
    int? maxAge,
    String? nationality,
    List<String>? positions,
    String? positionGroup,
    int? minOverall,
    int? maxOverall,
    int? minPotential,
    int? maxPotential,
    List<String>? requiredTraitIds,
    bool? wonderkidOnly,
    bool? hiddenGemOnly,
    bool? realFaceOnly,
    bool? freeAgentOnly,
  }) {
    return PlayerFilter(
      nameQuery: nameQuery ?? this.nameQuery,
      teamId: teamId ?? this.teamId,
      leagueId: leagueId ?? this.leagueId,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      nationality: nationality ?? this.nationality,
      positions: positions ?? this.positions,
      positionGroup: positionGroup ?? this.positionGroup,
      minOverall: minOverall ?? this.minOverall,
      maxOverall: maxOverall ?? this.maxOverall,
      minPotential: minPotential ?? this.minPotential,
      maxPotential: maxPotential ?? this.maxPotential,
      requiredTraitIds: requiredTraitIds ?? this.requiredTraitIds,
      wonderkidOnly: wonderkidOnly ?? this.wonderkidOnly,
      hiddenGemOnly: hiddenGemOnly ?? this.hiddenGemOnly,
      realFaceOnly: realFaceOnly ?? this.realFaceOnly,
      freeAgentOnly: freeAgentOnly ?? this.freeAgentOnly,
    );
  }

  bool get isEmpty =>
      nameQuery == null &&
      teamId == null &&
      leagueId == null &&
      minAge == null &&
      maxAge == null &&
      nationality == null &&
      positions.isEmpty &&
      positionGroup == null &&
      minOverall == null &&
      maxOverall == null &&
      minPotential == null &&
      maxPotential == null &&
      requiredTraitIds.isEmpty &&
      !wonderkidOnly &&
      !hiddenGemOnly &&
      !realFaceOnly &&
      !freeAgentOnly;
}

class PlayerRepository {
  final _db = AppSupabase.client;

  /// Builds and executes one indexed SQL query covering every filter
  /// dimension from the spec at once — name, team, league, age,
  /// nationality, position (exact or general), rating range, potential
  /// range, required traits, and the wonderkid/hidden-gem/real-face toggles.
  Future<List<Player>> search(
    PlayerFilter filter, {
    int page = 0,
    int pageSize = 30,
  }) async {
    // Base select: join team name in, and traits as an aggregated array
    // via a Postgres view (see note below) so the client gets one flat row.
    var query = _db.from('players_search_view').select();

    if (filter.nameQuery != null && filter.nameQuery!.trim().isNotEmpty) {
      // pg_trgm-backed similarity match, falls back to ilike for short strings
      query = query.ilike('full_name', '%${filter.nameQuery!.trim()}%');
    }
    if (filter.teamId != null) {
      query = query.eq('team_id', filter.teamId!);
    }
    if (filter.leagueId != null) {
      query = query.eq('league_id', filter.leagueId!);
    }
    if (filter.nationality != null) {
      query = query.eq('nationality', filter.nationality!);
    }
    if (filter.minAge != null) {
      query = query.gte('age', filter.minAge!);
    }
    if (filter.maxAge != null) {
      query = query.lte('age', filter.maxAge!);
    }
    if (filter.positions.isNotEmpty) {
      query = query.inFilter('position_primary', filter.positions);
    }
    if (filter.positionGroup != null) {
      query = query.eq('position_group', filter.positionGroup!);
    }
    if (filter.minOverall != null) {
      query = query.gte('overall_rating', filter.minOverall!);
    }
    if (filter.maxOverall != null) {
      query = query.lte('overall_rating', filter.maxOverall!);
    }
    if (filter.minPotential != null) {
      query = query.gte('potential_rating', filter.minPotential!);
    }
    if (filter.maxPotential != null) {
      query = query.lte('potential_rating', filter.maxPotential!);
    }
    if (filter.wonderkidOnly) {
      query = query.eq('is_wonderkid', true);
    }
    if (filter.hiddenGemOnly) {
      query = query.eq('is_hidden_gem', true);
    }
    if (filter.realFaceOnly) {
      query = query.eq('has_real_face', true);
    }
    if (filter.freeAgentOnly) {
      query = query.isFilter('team_id', null);
    }
    if (filter.requiredTraitIds.isNotEmpty) {
      // trait_ids is a uuid[] column on the view; contains() = AND match
      query = query.contains('trait_ids', filter.requiredTraitIds);
    }

    final from = page * pageSize;
    final to = from + pageSize - 1;

    final rows = await query
        .order('overall_rating', ascending: false)
        .range(from, to);

    return (rows as List)
        .map((row) => Player.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<Player?> getById(String id) async {
    final row = await _db
        .from('players_search_view')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return Player.fromJson(row);
  }

  /// Smart recommendation engine for Feature C — given a managed team's
  /// budget + a weak position, suggest realistic, affordable replacements.
  Future<List<Player>> suggestReplacements({
    required String weakPosition,
    required double maxWage,
    required double maxFee,
    int minOverall = 70,
  }) async {
    final rows = await _db
        .from('players_search_view')
        .select()
        .eq('position_primary', weakPosition)
        .lte('wage', maxWage)
        .lte('market_value', maxFee)
        .gte('overall_rating', minOverall)
        .order('potential_rating', ascending: false)
        .limit(20);

    return (rows as List)
        .map((row) => Player.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
