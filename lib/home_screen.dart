import 'package:flutter/material.dart';
import 'package:madarsago/home_widgets.dart';
import 'package:madarsago/main.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listAnimationController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _listAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const HomeScreenShimmer() : _buildHomeScreen(context);
  }

  Widget _buildHomeScreen(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDarkMode ? appDarkColor : Colors.grey[50]!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: scaffoldBg,
                automaticallyImplyLeading: false,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                scrolledUnderElevation: 0,
                expandedHeight: 60.0,
                flexibleSpace: const FlexibleSpaceBar(background: HomeHeader()),
              ),
              SliverPersistentHeader(
                delegate: HomeSearchBarDelegate(isDarkMode: isDarkMode),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LiveClockSection(),
                      const SizedBox(height: 24),
                      const CategorySection(),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, "Nearby Mosques"),
                      const SizedBox(height: 16),
                      const NearbyMasjidList(),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, "Nearby Madarsas"),
                      const SizedBox(height: 16),
                      const NearbyMadarsaList(),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, "Top Rated Madarsas"),
                      const SizedBox(height: 16),
                      RecommendedMadarsasList(
                        animationController: _listAnimationController,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontSize: 18, fontFamily: 'Bold'),
      ),
    );
  }
}

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDarkMode ? appDarkColor : Colors.grey[50]!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                expandedHeight: 60.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: HomeHeaderShimmer(),
                ),
              ),
              SliverPersistentHeader(
                delegate: HomeSearchBarShimmer(isDarkMode: isDarkMode),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LiveClockShimmer(),
                      const SizedBox(height: 24),
                      const CategorySectionShimmer(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _ShimmerBox(
                          height: 24,
                          width: 150,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const NearbyListShimmer(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _ShimmerBox(
                          height: 24,
                          width: 180,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const RecommendedListShimmer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry margin;

  const _ShimmerBox({
    required this.height,
    required this.width,
    required this.borderRadius,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(color: baseColor, borderRadius: borderRadius),
      ),
    );
  }
}

class HomeHeaderShimmer extends StatelessWidget {
  const HomeHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShimmerBox(
                height: 14,
                width: 60,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              _ShimmerBox(
                height: 16,
                width: 120,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          _ShimmerBox(
            height: 44,
            width: 44,
            borderRadius: BorderRadius.circular(22),
          ),
        ],
      ),
    );
  }
}

class HomeSearchBarShimmer extends SliverPersistentHeaderDelegate {
  final bool isDarkMode;
  HomeSearchBarShimmer({required this.isDarkMode});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: isDarkMode ? appDarkColor : Colors.grey[50]!,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
        child: _ShimmerBox(
          height: 56,
          width: double.infinity,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80.0;
  @override
  double get minExtent => 80.0;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}

class LiveClockShimmer extends StatelessWidget {
  const LiveClockShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: _ShimmerBox(
        height: 70,
        width: double.infinity,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class CategorySectionShimmer extends StatelessWidget {
  const CategorySectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) {
          return Column(
            children: [
              _ShimmerBox(
                height: 64,
                width: 64,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 8),
              _ShimmerBox(
                height: 14,
                width: 50,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class NearbyListShimmer extends StatelessWidget {
  const NearbyListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: _ShimmerBox(
              height: 230,
              width: 280,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}

class RecommendedListShimmer extends StatelessWidget {
  const RecommendedListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _ShimmerBox(
              height: 120,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }),
      ),
    );
  }
}
