import 'package:flutter/material.dart';
import 'package:madarsago/login_screen.dart';
import 'package:madarsago/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _onboardingPages = [
    OnboardingPageData(
      imageUrl: 'assets/images/location.webp',
      title: 'Find Madarsas & Masjids',
      description:
          'Instantly locate all Masjids and Madarsas nearby your current location.',
    ),
    OnboardingPageData(
      imageUrl: 'assets/images/info.webp',
      title: 'View Complete Details',
      description:
          'Get essential information, prayer timings, available courses, and facilities for every institute and mosque.',
    ),
    OnboardingPageData(
      imageUrl: 'assets/images/glob.webp',
      title: 'A Global, Growing Database',
      description:
          'From local listings to a worldwide directory, find the light of Deen wherever you go. Get started!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color inactiveColor = isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _goToHome,
                    child: Text(
                      'Skip',
                      style: textTheme.bodyMedium?.copyWith(
                        color: appPrimaryColor,
                        fontFamily: 'Bold',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingPages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _onboardingPages[index];
                    return OnboardingPageWidget(
                      imageUrl: page.imageUrl,
                      title: page.title,
                      description: page.description,
                      isActive: index == _currentPage,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingPages.length,
                  (index) => buildIndicator(index, inactiveColor),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingPages.length - 1) {
                        _goToHome();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Bold',
                        fontSize: 16,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _onboardingPages.length - 1
                          ? 'Get Started'
                          : (_currentPage == 1 ? 'Learn More' : 'Next'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(int index, Color inactiveColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? appPrimaryColor : inactiveColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPageWidget extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final bool isActive;

  const OnboardingPageWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.isActive,
  });

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _titleController;
  late AnimationController _descController;

  late Animation<Offset> _imageSlide;
  late Animation<double> _imageFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _descSlide;
  late Animation<double> _descFade;

  final Duration _duration = const Duration(milliseconds: 600);
  final Offset _beginOffset = const Offset(0, 0.5);

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(vsync: this, duration: _duration);
    _titleController = AnimationController(vsync: this, duration: _duration);
    _descController = AnimationController(vsync: this, duration: _duration);

    _imageSlide = Tween<Offset>(begin: _beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeOutCubic),
    );
    _imageFade = Tween<double>(begin: 0.0, end: 1.0).animate(_imageController);

    _titleSlide = Tween<Offset>(begin: _beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(_titleController);

    _descSlide = Tween<Offset>(begin: _beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _descController, curve: Curves.easeOutCubic),
    );
    _descFade = Tween<double>(begin: 0.0, end: 1.0).animate(_descController);

    if (widget.isActive) {
      _animate();
    }
  }

  @override
  void didUpdateWidget(covariant OnboardingPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animate();
    } else if (!widget.isActive && oldWidget.isActive) {
      _reset();
    }
  }

  void _animate() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _imageController.forward();
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _titleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _descController.forward();
    });
  }

  void _reset() {
    _imageController.reset();
    _titleController.reset();
    _descController.reset();
  }

  @override
  void dispose() {
    _imageController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _imageFade,
            child: SlideTransition(
              position: _imageSlide,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.imageUrl,
                  height: 300,
                  width: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeTransition(
            opacity: _titleFade,
            child: SlideTransition(
              position: _titleSlide,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(fontFamily: 'Bold'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _descFade,
            child: SlideTransition(
              position: _descSlide,
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'TagRegular',
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String imageUrl;
  final String title;
  final String description;

  OnboardingPageData({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}
