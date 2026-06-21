import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/squad_builder_provider.dart';
import '../../widgets/glow_button.dart';

/// Developer: Coach: Danilo
///
/// Feature C (Parallel Play squad builder) + entry point for Feature D
/// (P2P sharing via invite code). Pitch layout is intentionally simple
/// here — formation-specific coordinate maps would expand `_slotsFor()`.
class SquadBuilderScreen extends ConsumerWidget {
  const SquadBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final squadState = ref.watch(squadBuilderProvider);

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('Squad Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add, color: AppColors.neonCyan),
            tooltip: 'Join via invite code',
            onPressed: () => _showJoinDialog(context, ref),
          ),
        ],
      ),
      body: squadState.when(
        data: (squad) {
          if (squad == null) {
            return _EmptyState(
              onCreate: () => ref.read(squadBuilderProvider.notifier).createNew(
                    name: 'My Career Squad',
                  ),
            );
          }
          return _SquadView(squadId: squad.id, inviteCode: squad.inviteCode, formation: squad.formation);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
        error: (e, _) => Center(
          child: Text('$e', style: TextStyle(color: AppColors.neonWhite.withOpacity(0.6))),
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: const Text('Join shared squad', style: TextStyle(color: AppColors.neonWhite)),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
          style: const TextStyle(color: AppColors.neonWhite, letterSpacing: 4, fontSize: 18),
          decoration: const InputDecoration(hintText: 'ABC123'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(squadBuilderProvider.notifier).joinByInviteCode(controller.text);
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_customize, size: 56, color: AppColors.electricBlue.withOpacity(0.6)),
            const SizedBox(height: 16),
            const Text(
              'No squad yet',
              style: TextStyle(color: AppColors.neonWhite, fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Build a squad for your current career save, or join a friend\'s with an invite code.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.neonWhite.withOpacity(0.55), fontSize: 13),
            ),
            const SizedBox(height: 24),
            GlowButton(label: 'Create Squad', icon: Icons.add, onPressed: onCreate),
          ],
        ),
      ),
    );
  }
}

class _SquadView extends ConsumerWidget {
  final String squadId;
  final String inviteCode;
  final String formation;

  const _SquadView({required this.squadId, required this.inviteCode, required this.formation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribing here keeps this screen reactive to realtime slot
    // changes pushed from a friend's device in the same squad.
    ref.watch(squadSlotsStreamProvider(squadId));

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.share, color: AppColors.neonCyan, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invite code', style: TextStyle(fontSize: 11, color: AppColors.neonWhite.withOpacity(0.55))),
                    Text(
                      inviteCode,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
              ),
              Text(formation, style: const TextStyle(color: AppColors.neonWhite, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Formation pitch UI renders here\n(tap a position to assign from Scouting Network)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }
}
