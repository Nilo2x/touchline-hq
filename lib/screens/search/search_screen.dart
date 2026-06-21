import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/player_search_provider.dart';
import '../../services/player_repository.dart';
import '../../widgets/player_card.dart';

/// Developer: Coach: Danilo
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(playerFilterProvider);
    final notifier = ref.read(playerFilterProvider.notifier);
    final resultsAsync = ref.watch(playerSearchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('Scouting Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neonCyan),
            onPressed: notifier.reset,
            tooltip: 'Reset filters',
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            onChanged: notifier.setNameQuery,
          ),
          _QuickFilterRow(filter: filter, notifier: notifier),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButton(
                    label: 'Position',
                    active: filter.positions.isNotEmpty || filter.positionGroup != null,
                    onTap: () => _showPositionSheet(context, filter, notifier),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterButton(
                    label: 'Rating / Potential',
                    active: filter.minOverall != null || filter.minPotential != null,
                    onTap: () => _showRatingSheet(context, filter, notifier),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterButton(
                    label: 'Age',
                    active: filter.minAge != null || filter.maxAge != null,
                    onTap: () => _showAgeSheet(context, filter, notifier),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: resultsAsync.when(
              data: (players) {
                if (players.isEmpty) {
                  return Center(
                    child: Text(
                      'No players match these filters yet.',
                      style: TextStyle(color: AppColors.neonWhite.withOpacity(0.5)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: players.length,
                  itemBuilder: (context, i) => PlayerCard(player: players[i]),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.neonCyan),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load players.\n$e',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.neonWhite.withOpacity(0.6)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPositionSheet(BuildContext context, PlayerFilter filter, PlayerFilterNotifier notifier) {
    const positions = [
      'GK', 'CB', 'LB', 'RB', 'LWB', 'RWB',
      'CDM', 'CM', 'CAM', 'LM', 'RM', 'LW', 'RW', 'CF', 'ST',
    ];
    const groups = ['GK', 'DEF', 'MID', 'FWD'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('General position', style: TextStyle(color: AppColors.neonWhite, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: groups.map((g) {
                    final selected = filter.positionGroup == g;
                    return ChoiceChip(
                      label: Text(g),
                      selected: selected,
                      onSelected: (_) {
                        notifier.setPositionGroup(selected ? null : g);
                        setSheetState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Text('Exact position', style: TextStyle(color: AppColors.neonWhite, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: positions.map((p) {
                    final selected = filter.positions.contains(p);
                    return FilterChip(
                      label: Text(p),
                      selected: selected,
                      onSelected: (_) {
                        notifier.togglePosition(p);
                        setSheetState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRatingSheet(BuildContext context, PlayerFilter filter, PlayerFilterNotifier notifier) {
    RangeValues overall = RangeValues(
      (filter.minOverall ?? 40).toDouble(),
      (filter.maxOverall ?? 99).toDouble(),
    );
    RangeValues potential = RangeValues(
      (filter.minPotential ?? 40).toDouble(),
      (filter.maxPotential ?? 99).toDouble(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Rating  ${overall.start.round()}–${overall.end.round()}',
                    style: const TextStyle(color: AppColors.neonWhite, fontWeight: FontWeight.w700)),
                RangeSlider(
                  values: overall,
                  min: 40,
                  max: 99,
                  activeColor: AppColors.electricBlue,
                  onChanged: (v) {
                    setSheetState(() => overall = v);
                    notifier.setOverallRange(v.start.round(), v.end.round());
                  },
                ),
                const SizedBox(height: 12),
                Text('Potential Rating  ${potential.start.round()}–${potential.end.round()}',
                    style: const TextStyle(color: AppColors.neonWhite, fontWeight: FontWeight.w700)),
                RangeSlider(
                  values: potential,
                  min: 40,
                  max: 99,
                  activeColor: AppColors.neonCyan,
                  onChanged: (v) {
                    setSheetState(() => potential = v);
                    notifier.setPotentialRange(v.start.round(), v.end.round());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAgeSheet(BuildContext context, PlayerFilter filter, PlayerFilterNotifier notifier) {
    RangeValues age = RangeValues(
      (filter.minAge ?? 16).toDouble(),
      (filter.maxAge ?? 40).toDouble(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Age  ${age.start.round()}–${age.end.round()}',
                    style: const TextStyle(color: AppColors.neonWhite, fontWeight: FontWeight.w700)),
                RangeSlider(
                  values: age,
                  min: 16,
                  max: 40,
                  activeColor: AppColors.electricBlue,
                  onChanged: (v) {
                    setSheetState(() => age = v);
                    notifier.setAgeRange(v.start.round(), v.end.round());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.neonWhite),
        decoration: const InputDecoration(
          hintText: 'Search player, team, or league...',
          prefixIcon: Icon(Icons.search, color: AppColors.neonCyan),
        ),
      ),
    );
  }
}

class _QuickFilterRow extends StatelessWidget {
  final PlayerFilter filter;
  final PlayerFilterNotifier notifier;
  const _QuickFilterRow({required this.filter, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('Wonderkid'),
            avatar: const Icon(Icons.auto_awesome, size: 16),
            selected: filter.wonderkidOnly,
            onSelected: (_) => notifier.toggleWonderkid(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Hidden Gem'),
            avatar: const Icon(Icons.diamond_outlined, size: 16),
            selected: filter.hiddenGemOnly,
            onSelected: (_) => notifier.toggleHiddenGem(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Real Face'),
            avatar: const Icon(Icons.face_retouching_natural, size: 16),
            selected: filter.realFaceOnly,
            onSelected: (_) => notifier.toggleRealFace(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Free Agent'),
            avatar: const Icon(Icons.person_off_outlined, size: 16),
            selected: filter.freeAgentOnly,
            onSelected: (_) => notifier.toggleFreeAgent(),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.electricBlue.withOpacity(0.18) : AppColors.charcoalLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.neonCyan : AppColors.electricBlue.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: active ? AppColors.neonCyan : AppColors.neonWhite.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
