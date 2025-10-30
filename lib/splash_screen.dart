import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MadarsaGo Home")),
      body: const Center(child: Text("Welcome to MadarsaGo!")),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Timer(
      const Duration(seconds: 3),
          () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color greyColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final Color subtleGreyColor = isDarkMode ? Colors.grey[400]! : Colors.grey[500]!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _animation,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 40,
                          width: 40,
                          color: isDarkMode ? Colors.white : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "MadarsaGo",
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Find the light of Deen near you",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/cocode.png',
                    height: 20,
                    width: 20,
                    color: subtleGreyColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "From CoCode Studio",
                    style: textTheme.bodySmall?.copyWith(
                      color: subtleGreyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}