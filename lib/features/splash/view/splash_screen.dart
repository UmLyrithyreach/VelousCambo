import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/features/auth/viewmodel/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late AnimationController _contentController;
  late AnimationController _dotController;

  late Animation<double> _wheelSpin;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _dotOpacity;

  @override
  void initState() {
    super.initState();

    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _wheelSpin = Tween<double>(begin: 0, end: 3 * math.pi).animate(
      CurvedAnimation(parent: _wheelController, curve: Curves.easeInOut),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0, end: 0.85).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );
    _dotOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _dotController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _wheelController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _dotController.forward();

    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) _navigate();
  }

  void _navigate() {
    final auth = context.read<AuthViewModel>();
    Navigator.of(context).pushReplacementNamed(
      auth.isAuthenticated ? '/home' : '/login',
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _contentController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.splashBgEnd],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated bicycle wheel
              AnimatedBuilder(
                animation: _wheelController,
                builder: (_, __) => Transform.rotate(
                  angle: _wheelSpin.value,
                  child: CustomPaint(
                    size: const Size(140, 140),
                    painter: _BicycleWheelPainter(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // App name + tagline
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Column(
                    children: [
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: const Text(
                            'VelousCambo',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _subtitleOpacity,
                        child: const Text(
                          'Bike Sharing in Phnom Penh',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Loading dots
              FadeTransition(
                opacity: _dotOpacity,
                child: const _LoadingDots(),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bicycle Wheel Painter ────────────────────────────────────────────────────

class _BicycleWheelPainter extends CustomPainter {
  final Color color;
  _BicycleWheelPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.88;
    final hubRadius = outerRadius * 0.08;

    final rimPaint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final spokePaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final hubPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Outer rim
    canvas.drawCircle(center, outerRadius - 3, rimPaint);

    // Inner rim
    canvas.drawCircle(center, innerRadius * 0.72, rimPaint..strokeWidth = 2);

    // Spokes (8)
    const spokeCount = 8;
    for (int i = 0; i < spokeCount; i++) {
      final angle = (i * 2 * math.pi) / spokeCount;
      final inner = Offset(
        center.dx + hubRadius * 1.2 * math.cos(angle),
        center.dy + hubRadius * 1.2 * math.sin(angle),
      );
      final outer = Offset(
        center.dx + innerRadius * 0.72 * math.cos(angle),
        center.dy + innerRadius * 0.72 * math.sin(angle),
      );
      canvas.drawLine(inner, outer, spokePaint);
    }

    // Hub
    canvas.drawCircle(
      center,
      hubRadius * 1.5,
      Paint()
        ..color = AppColors.splashBgEnd
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(center, hubRadius, hubPaint);
  }

  @override
  bool shouldRepaint(_BicycleWheelPainter old) => old.color != color;
}

// ─── Loading Dots ─────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * math.sin(t * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5 + 0.5 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
