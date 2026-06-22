import '../core/utils/invite_code.dart';
import '../models/squad.dart';
import 'supabase_client.dart';

/// Developer: Coach: Danilo
///
/// Implements Feature D (P2P squad sharing) and the persistence side
/// of Feature C (Parallel Play squad builder).
class SquadRepository {
  final _db = AppSupabase.client;

  /// Returns the current user's id, or throws a readable error instead
  /// of an unreadable null-check crash if no one is signed in yet
  /// (should not happen if main.dart's ensureSignedIn() succeeded).
  String get _requireUserId {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw Exception('No signed-in user yet. Check your internet connection and try again.');
    }
    return user.id;
  }

  Future<Squad> createSquad({
    required String name,
    String? managedTeamId,
    String formation = '4-3-3',
    double? transferBudget,
    double? wageBudget,
    bool isPublic = false,
  }) async {
    final userId = _requireUserId;

    // Retry on the rare collision with another squad's invite code.
    String code = InviteCode.generate();
    for (var attempt = 0; attempt < 5; attempt++) {
      final existing = await _db
          .from('squads')
          .select('id')
          .eq('invite_code', code)
          .maybeSingle();
      if (existing == null) break;
      code = InviteCode.generate();
    }

    final row = await _db
        .from('squads')
        .insert({
          'owner_id': userId,
          'name': name,
          'managed_team_id': managedTeamId,
          'formation': formation,
          'transfer_budget': transferBudget,
          'wage_budget': wageBudget,
          'invite_code': code,
          'is_public': isPublic,
        })
        .select()
        .single();

    return Squad.fromJson(row);
  }

  Future<List<Squad>> mySquads() async {
    final userId = _requireUserId;
    final rows = await _db
        .from('squads')
        .select('*, squad_slots(*)')
        .eq('owner_id', userId)
        .order('updated_at', ascending: false);
    return (rows as List).map((r) => Squad.fromJson(r)).toList();
  }

  Future<Squad?> getSquad(String squadId) async {
    final row = await _db
        .from('squads')
        .select('*, squad_slots(*)')
        .eq('id', squadId)
        .maybeSingle();
    if (row == null) return null;
    return Squad.fromJson(row);
  }

  /// Joins a shared squad by its 6-character invite code. Looks up by
  /// code (never by raw squad id) so codes can't be guessed/enumerated
  /// from squad ids; RLS only allows the insert if the code resolves.
  Future<Squad> joinByCode(String code) async {
    final normalized = InviteCode.normalize(code);
    if (!InviteCode.isValidFormat(normalized)) {
      throw const FormatException('Invite code must be 6 characters, letters and numbers only.');
    }

    final squadRow = await _db
        .from('squads')
        .select('*, squad_slots(*)')
        .eq('invite_code', normalized)
        .maybeSingle();

    if (squadRow == null) {
      throw Exception('No squad found for that invite code.');
    }

    final squad = Squad.fromJson(squadRow);
    final userId = _requireUserId;

    if (squad.ownerId != userId) {
      await _db.from('squad_members').upsert({
        'squad_id': squad.id,
        'user_id': userId,
        'role': 'viewer',
      });
    }

    return squad;
  }

  Future<void> updateSlot({
    required String squadId,
    required int slotIndex,
    required String slotPosition,
    String? playerId,
  }) async {
    await _db.from('squad_slots').upsert({
      'squad_id': squadId,
      'slot_index': slotIndex,
      'slot_position': slotPosition,
      'player_id': playerId,
    }, onConflict: 'squad_id,slot_index');
  }

  Future<void> rateSquad(String squadId, int rating) async {
    final userId = _requireUserId;
    await _db.from('squad_ratings').upsert({
      'squad_id': squadId,
      'user_id': userId,
      'rating': rating,
    });
  }

  Future<Squad> cloneSquad(Squad source, {required String newName}) async {
    final clone = await createSquad(
      name: newName,
      managedTeamId: source.managedTeamId,
      formation: source.formation,
      transferBudget: source.transferBudget,
      wageBudget: source.wageBudget,
    );
    for (final slot in source.slots) {
      await updateSlot(
        squadId: clone.id,
        slotIndex: slot.slotIndex,
        slotPosition: slot.slotPosition,
        playerId: slot.playerId,
      );
    }
    return clone;
  }

  /// Realtime stream of slot changes for a squad — both the owner's
  /// device and any joined viewer's device receive pushes the instant
  /// a slot is updated, with no polling.
  ///
  /// NOTE: `.stream()` filters are applied client-side against the
  /// primaryKey-backed change feed. `.eq()` on a non-primary-key column
  /// (as used here) works reliably; avoid `.inFilter()` on `.stream()`
  /// queries, which has had inconsistent behavior across supabase_flutter
  /// versions — prefer a server-side view/RPC if multi-id stream filtering
  /// is ever needed.
  Stream<List<Map<String, dynamic>>> watchSquadSlots(String squadId) {
    return _db
        .from('squad_slots')
        .stream(primaryKey: ['id'])
        .eq('squad_id', squadId);
  }
}
