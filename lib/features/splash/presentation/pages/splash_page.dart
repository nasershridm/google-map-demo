import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieCtrl;

  @override
  void initState() {
    super.initState();

    // Hide system UI for a true full-screen splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _lottieCtrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onLottieLoaded(LottieComposition composition) {
    // Sync controller duration to animation length, then play once
    _lottieCtrl
      ..duration = composition.duration
      ..forward().then((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // deep dark background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Subtle radial glow behind the animation ──────────────────────
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E88E5).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Lottie animation + brand name ────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/splash-lottie.json',
                controller: _lottieCtrl,
                width: 260,
                height: 260,
                fit: BoxFit.contain,
                onLoaded: _onLottieLoaded,
              ),

              const SizedBox(height: 32),

              // Arabic company name "دندن"
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'دندن',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Colors.white, // masked by ShaderMask
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle tagline
              Text(
                'Smart GPS Tracking',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 3,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),

          // ── Bottom version label ─────────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.2),
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
