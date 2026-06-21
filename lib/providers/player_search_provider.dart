import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../services/player_repository.dart';

/// Developer: Coach: Danilo

final playerRepositoryProvider = Provider<PlayerRepository>((ref) => PlayerRepository());

/// Holds the current filter selection — every widget on the Search
/// screen reads/writes this and the result list rebuilds automatically.
class PlayerFilterNotifier extends StateNotifier<PlayerFilter> {
  PlayerFilterNotifier() : super(const PlayerFilter());

  void setNameQuery(String? q) => state = state.copyWith(nameQuery: q);
  void setTeam(String? teamId) => state = state.copyWith(teamId: teamId);
  void setLeague(String? leagueId) => state = state.copyWith(leagueId: leagueId);
  void setNationality(String? nat) => state = state.copyWith(nationality: nat);
  void setAgeRange(int? min, int? max) =>
      state = state.copyWith(minAge: min, maxAge: max);
  void setOverallRange(int? min, int? max) =>
      state = state.copyWith(minOverall: min, maxOverall: max);
  void setPotentialRange(int? min, int? max) =>
      state = state.copyWith(minPotential: min, maxPotential: max);
  void setPositionGroup(String? group) =>
      state = state.copyWith(positionGroup: group);

  void togglePosition(String pos) {
    final list = [...state.positions];
    if (list.contains(pos)) {
      list.remove(pos);
    } else {
      list.add(pos);
    }
    state = state.copyWith(positions: list);
  }

  void toggleTrait(String traitId) {
    final list = [...state.requiredTraitIds];
    if (list.contains(traitId)) {
      list.remove(traitId);
    } else {
      list.add(traitId);
    }
    state = state.copyWith(requiredTraitIds: list);
  }

  void toggleWonderkid() => state = state.copyWith(wonderkidOnly: !state.wonderkidOnly);
  void toggleHiddenGem() => state = state.copyWith(hiddenGemOnly: !state.hiddenGemOnly);
  void toggleRealFace() => state = state.copyWith(realFaceOnly: !state.realFaceOnly);
  void toggleFreeAgent() => state = state.copyWith(freeAgentOnly: !state.freeAgentOnly);

  void reset() => state = const PlayerFilter();
}

final playerFilterProvider =
    StateNotifierProvider<PlayerFilterNotifier, PlayerFilter>(
  (ref) => PlayerFilterNotifier(),
);

/// Debounced-by-rebuild search results. Riverpod's autoDispose + family
/// would also work for paging; kept simple here with a manual page param.
final playerSearchResultsProvider =
    FutureProvider.autoDispose<List<Player>>((ref) async {
  final filter = ref.watch(playerFilterProvider);
  final repo = ref.watch(playerRepositoryProvider);
  return repo.search(filter);
});
