import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/player.dart';

/// Developer: Coach: Danilo
///
/// Displays: photo (or deterministic generated-avatar fallback), explicit
/// Real Face marker, OVR/POT badges, and trait chips — per Feature A spec.
class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;

  const PlayerCard({super.key, required this.player, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ovrColor = AppColors.ratingColor(player.overallRating);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ovrColor.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            _Avatar(player: player, color: ovrColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          player.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.neonWhite,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (player.hasRealFace) const _RealFaceBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.positionPrimary} · ${player.teamName ?? 'Free Agent'} · ${player.nationality}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neonWhite.withOpacity(0.55),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (player.traits.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: player.traits
                          .take(3)
                          .map((t) => _TraitChip(label: t))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _RatingPill(value: player.overallRating, color: ovrColor, label: 'OVR'),
                const SizedBox(height: 6),
                _RatingPill(
                  value: player.potentialRating,
                  color: AppColors.neonCyan,
                  label: 'POT',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Player player;
  final Color color;
  const _Avatar({required this.player, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)],
      ),
      child: ClipOval(
        child: player.photoUrl != null
            ? Image.network(
                player.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _GeneratedAvatar(seed: player.avatarFallbackSeed),
              )
            : _GeneratedAvatar(seed: player.avatarFallbackSeed),
      ),
    );
  }
}

/// Deterministic placeholder avatar (no licensed imagery) — a simple
/// gradient + initials derived from a hash of the player's id, so the
/// same fictional/unlicensed player always renders the same "face".
class _GeneratedAvatar extends StatelessWidget {
  final String seed;
  const _GeneratedAvatar({required this.seed});

  @override
  Widget build(BuildContext context) {
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    final hue = (hash * 37) % 360;
    final color = HSLColor.fromAHSL(1, hue.toDouble(), 0.65, 0.45).toColor();
    return Container(
      color: color,
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: Colors.white70, size: 28),
    );
  }
}

class _RealFaceBadge extends StatelessWidget {
  const _RealFaceBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Real Face scan available in-game',
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.neonCyan.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.6)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.face_retouching_natural, size: 11, color: AppColors.neonCyan),
            SizedBox(width: 3),
            Text('RF', style: TextStyle(fontSize: 9, color: AppColors.neonCyan, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  final String label;
  const _TraitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.neonWhite),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final int value;
  final Color color;
  final String label;
  const _RatingPill({required this.value, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            '$value',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.8))),
      ],
    );
  }
}
