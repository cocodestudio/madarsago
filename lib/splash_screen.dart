import 'dart:async';
import 'package:flutter/material.dart';
import 'package:madarsago/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madarsago/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madarsago/profile_provider.dart';

import 'onnboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;
  late Animation<double> _footerFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    final logoCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(logoCurve);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(logoCurve);
    final taglineCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    );
    _taglineFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(taglineCurve);
    _taglineSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(taglineCurve);
    _footerFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();

    Timer(const Duration(milliseconds: 3500), () {
      _checkAuthAndOnboarding();
    });
  }

  void _checkAuthAndOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final user = ref.read(firebaseAuthProvider).currentUser;

    Widget destinationScreen;

    if (hasSeenOnboarding) {
      if (user != null) {
        destinationScreen = const HomeScreen();
      } else {
        destinationScreen = const LoginScreen();
      }
    } else {
      destinationScreen = const OnboardingScreen();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => destinationScreen),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color footerIconColor = textTheme.bodySmall!.color!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Madarsa", style: textTheme.headlineLarge),
                              Text(
                                "Go",
                                style: textTheme.headlineLarge?.copyWith(
                                  fontFamily: 'Regular',
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SlideTransition(
                        position: _taglineSlideAnimation,
                        child: FadeTransition(
                          opacity: _taglineFadeAnimation,
                          child: Text(
                            "Find the light of Deen near you",
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              fontFamily: 'TagRegular',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: _footerFadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/cocode.png',
                      height: 20,
                      width: 20,
                      color: footerIconColor,
                    ),
                    const SizedBox(width: 8),
                    Text("From CoCode Studio", style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}