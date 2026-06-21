import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Developer: Coach: Danilo
///
/// Cinematic sequence: silhouette portraits crossfade in sequence
/// (legends → future wonderkids), then the screen settles into a
/// glowing "Coach: Danilo" brand mark before pushing the dashboard.
///
/// NOTE ON IMAGERY: Real photographs of named real players (Pelé,
/// Zidane, Ronaldo, Yamal, Endrick, etc.) are licensed likenesses we
/// can't source or embed here. This screen uses abstract glowing
/// silhouette placeholders with the *positional role* labeled instead
/// of a real name — swap the asset paths in `_legendAssets` for your
/// own licensed imagery and the animation timing works unchanged.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _LegendFrame {
  final String label; // generic role label, not a real person's name
  final IconData icon;
  const _LegendFrame(this.label, this.icon);
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _crossfadeController;
  late final AnimationController _brandController;

  int _frameIndex = 0;
  bool _showBrand = false;

  // Placeholder roster — replace with real licensed photo assets.
  // Era 1: silhouettes representing past "legend" archetypes.
  // Era 2: silhouettes representing "future wonderkid" archetypes.
  final List<_LegendFrame> _frames = const [
    _LegendFrame('Legend · Playmaker', Icons.sports_soccer),
    _LegendFrame('Legend · Goal Machine', Icons.sports_soccer),
    _LegendFrame('Legend · The Maestro', Icons.sports_soccer),
    _LegendFrame('Future Star · Wonderkid', Icons.auto_awesome),
    _LegendFrame('Future Star · Next Icon', Icons.auto_awesome),
  ];

  @override
  void initState() {
    super.initState();
    _crossfadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (var i = 0; i < _frames.length; i++) {
      setState(() => _frameIndex = i);
      await _crossfadeController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 550));
      await _crossfadeController.reverse();
    }
    setState(() => _showBrand = true);
    await _brandController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 900));
    widget.onComplete();
  }

  @override
  void dispose() {
    _crossfadeController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Stack(
        children: [
          // Cyberpunk grid backdrop
          const _GridBackdrop(),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: _showBrand
                  ? _BrandReveal(controller: _brandController)
                  : FadeTransition(
                      opacity: _crossfadeController,
                      child: _LegendPortrait(frame: _frames[_frameIndex]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendPortrait extends StatelessWidget {
  final _LegendFrame frame;
  const _LegendPortrait({required this.frame});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.glowGradient,
            boxShadow: [
              BoxShadow(color: AppColors.neonCyan.withOpacity(0.5), blurRadius: 40, spreadRadius: 4),
            ],
          ),
          child: Icon(frame.icon, size: 72, color: AppColors.deepNavy),
        ),
        const SizedBox(height: 24),
        Text(
          frame.label,
          style: const TextStyle(
            color: AppColors.neonWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _BrandReveal extends StatelessWidget {
  final AnimationController controller;
  const _BrandReveal({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final glow = Curves.easeOutCubic.transform(controller.value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (rect) => AppColors.glowGradient.createShader(rect),
              child: Text(
                AppConstants.appName.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white.withOpacity(0.2 + glow * 0.8),
                  shadows: [
                    Shadow(color: AppColors.neonCyan.withOpacity(glow), blurRadius: 30),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Opacity(
              opacity: glow,
              child: Text(
                AppConstants.developerCredit,
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 1.5,
                  color: AppColors.neonCyan.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Subtle animated grid overlay for the cyberpunk/futuristic pitch feel.
class _GridBackdrop extends StatelessWidget {
  const _GridBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomPaint(painter: _GridPainter()),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.electricBlue.withOpacity(0.06)
      ..strokeWidth = 1;
    const step = 32.0;
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
