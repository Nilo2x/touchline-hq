import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/squad.dart';
import '../services/squad_repository.dart';

/// Developer: Coach: Danilo

final squadRepositoryProvider = Provider<SquadRepository>((ref) => SquadRepository());

/// Active squad being edited/viewed. Null until a squad is created,
/// loaded, or joined via invite code.
class SquadBuilderNotifier extends StateNotifier<AsyncValue<Squad?>> {
  final SquadRepository _repo;
  SquadBuilderNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> createNew({
    required String name,
    String? managedTeamId,
    String formation = '4-3-3',
    double? transferBudget,
    double? wageBudget,
  }) async {
    state = const AsyncValue.loading();
    try {
      final squad = await _repo.createSquad(
        name: name,
        managedTeamId: managedTeamId,
        formation: formation,
        transferBudget: transferBudget,
        wageBudget: wageBudget,
      );
      state = AsyncValue.data(squad);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadSquad(String squadId) async {
    state = const AsyncValue.loading();
    try {
      final squad = await _repo.getSquad(squadId);
      state = AsyncValue.data(squad);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// This is the entry point for Feature D: a friend types in a 6-char
  /// code, this calls the repository which resolves it server-side and
  /// adds them as a viewer — then loads the squad into local state.
  Future<void> joinByInviteCode(String code) async {
    state = const AsyncValue.loading();
    try {
      final squad = await _repo.joinByCode(code);
      state = AsyncValue.data(squad);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setSlot({
    required int slotIndex,
    required String slotPosition,
    String? playerId,
  }) async {
    final current = state.value;
    if (current == null) return;
    await _repo.updateSlot(
      squadId: current.id,
      slotIndex: slotIndex,
      slotPosition: slotPosition,
      playerId: playerId,
    );
    // Optimistic local update; the realtime stream (below) reconciles
    // shortly after with the authoritative server state.
    final updatedSlots = [...current.slots];
    final idx = updatedSlots.indexWhere((s) => s.slotIndex == slotIndex);
    final newSlot = SquadSlot(
      id: idx >= 0 ? updatedSlots[idx].id : 'pending-$slotIndex',
      playerId: playerId,
      slotPosition: slotPosition,
      slotIndex: slotIndex,
    );
    if (idx >= 0) {
      updatedSlots[idx] = newSlot;
    } else {
      updatedSlots.add(newSlot);
    }
    state = AsyncValue.data(Squad(
      id: current.id,
      ownerId: current.ownerId,
      name: current.name,
      managedTeamId: current.managedTeamId,
      formation: current.formation,
      transferBudget: current.transferBudget,
      wageBudget: current.wageBudget,
      inviteCode: current.inviteCode,
      isPublic: current.isPublic,
      ratingAvg: current.ratingAvg,
      ratingCount: current.ratingCount,
      slots: updatedSlots,
    ));
  }

  void clear() => state = const AsyncValue.data(null);
}

final squadBuilderProvider =
    StateNotifierProvider<SquadBuilderNotifier, AsyncValue<Squad?>>(
  (ref) => SquadBuilderNotifier(ref.watch(squadRepositoryProvider)),
);

/// Live realtime stream of slot changes for the currently active squad —
/// drives both devices (owner + joined viewer) staying in sync without
/// either one polling.
final squadSlotsStreamProvider =
    StreamProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, squadId) => ref.watch(squadRepositoryProvider).watchSquadSlots(squadId),
);

final mySquadsProvider = FutureProvider.autoDispose<List<Squad>>((ref) {
  return ref.watch(squadRepositoryProvider).mySquads();
});
