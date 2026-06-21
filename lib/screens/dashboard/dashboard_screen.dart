import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/glow_button.dart';
import '../search/search_screen.dart';
import '../squad_builder/squad_builder_screen.dart';

/// Developer: Coach: Danilo
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: Stack(
          children: [
            const _StadiumGridBackground(),
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(child: _Header()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(child: _SeasonSnapshotCard()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'QUICK ACCESS',
                      style: TextStyle(
                        color: AppColors.neonWhite.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.15,
                    ),
                    delegate: SliverChildListDelegate([
                      _DashboardTile(
                        icon: Icons.travel_explore,
                        title: 'Scouting Network',
                        subtitle: 'Search & filter',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        ),
                      ),
                      _DashboardTile(
                        icon: Icons.dashboard_customize,
                        title: 'Squad Builder',
                        subtitle: 'Parallel Play',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SquadBuilderScreen()),
                        ),
                      ),
                      _DashboardTile(
                        icon: Icons.groups_2,
                        title: 'Tactical Room',
                        subtitle: 'Shared squads & chat',
                        onTap: () {},
                      ),
                      _DashboardTile(
                        icon: Icons.swap_horiz,
                        title: 'Transfer Feed',
                        subtitle: 'Latest market moves',
                        onTap: () {},
                      ),
                    ]),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.neonWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.developerCredit,
              style: TextStyle(fontSize: 11, color: AppColors.neonCyan.withOpacity(0.85)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.charcoalLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.electricBlue.withOpacity(0.3)),
          ),
          child: const Icon(Icons.notifications_none, color: AppColors.neonWhite, size: 20),
        ),
      ],
    );
  }
}

class _SeasonSnapshotCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.electricBlue.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: AppColors.electricBlue.withOpacity(0.12), blurRadius: 30),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR CAREER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: AppColors.neonWhite.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'No active save linked yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.neonWhite),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a squad to start tracking your Parallel Play save.',
            style: TextStyle(fontSize: 12.5, color: AppColors.neonWhite.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          GlowButton(label: 'Start Tracking', icon: Icons.add, onPressed: () {}),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.electricBlue.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.neonCyan, size: 22),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.neonWhite)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11.5, color: AppColors.neonWhite.withOpacity(0.55))),
          ],
        ),
      ),
    );
  }
}

class _StadiumGridBackground extends StatelessWidget {
  const _StadiumGridBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomPaint(painter: _FaintGridPainter()),
      ),
    );
  }
}

class _FaintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.electricBlue.withOpacity(0.04)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
