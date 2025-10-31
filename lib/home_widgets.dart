import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:madarsago/main.dart';
import 'package:intl/intl.dart';
import 'package:madarsago/profile_screen.dart';

class Place {
  final String imageUrl;
  final String name;
  final String location;
  final double rating;

  Place({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
  });
}

final List<Place> nearbyMasjids = [
  Place(
    imageUrl: 'https://placehold.co/400x300/297373/FFFFFF?text=Masjid+A',
    name: "Jama Masjid",
    location: "2.1km away",
    rating: 4.8,
  ),
  Place(
    imageUrl: 'https://placehold.co/400x300/CA895F/FFFFFF?text=Masjid+B',
    name: "Masjid e Nabawi",
    location: "3.5km away",
    rating: 4.9,
  ),
  Place(
    imageUrl: 'https://placehold.co/400x300/A491D3/FFFFFF?text=Masjid+C',
    name: "Al-Noor Mosque",
    location: "1.2km away",
    rating: 4.5,
  ),
];

final List<Place> nearbyMadarsas = [
  Place(
    imageUrl: 'https://placehold.co/400x300/1F1A38/FFFFFF?text=Madarsa+A',
    name: "Jamia Millia",
    location: "4.2km away",
    rating: 4.7,
  ),
  Place(
    imageUrl: 'https://placehold.co/400x300/D0DDD7/000000?text=Madarsa+B',
    name: "Darul Uloom",
    location: "5.0km away",
    rating: 4.6,
  ),
  Place(
    imageUrl: 'https://placehold.co/400x300/A491D3/FFFFFF?text=Madarsa+C',
    name: "Madarsa Al-Faizan",
    location: "6.1km away",
    rating: 4.5,
  ),
];

final List<Place> topMadarsas = [
  Place(
    imageUrl: 'https://placehold.co/300x300/297373/FFFFFF?text=Madarsa+A',
    name: "Darul Uloom Deoband",
    location: "Deoband, UP",
    rating: 4.9,
  ),
  Place(
    imageUrl: 'https://placehold.co/300x300/CA895F/FFFFFF?text=Madarsa+B',
    name: "Jamia Nizamia",
    location: "Hyderabad, TS",
    rating: 4.7,
  ),
  Place(
    imageUrl: 'https://placehold.co/300x300/A491D3/FFFFFF?text=Madarsa+C',
    name: "Al-Jamiatul Ashrafia",
    location: "Mubarakpur, UP",
    rating: 4.8,
  ),
  Place(
    imageUrl: 'https://placehold.co/300x300/1F1A38/FFFFFF?text=Madarsa+D',
    name: "Raza Academy",
    location: "Bareilly, UP",
    rating: 4.6,
  ),
];

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Location",
                  style: textTheme.bodySmall?.copyWith(
                    fontFamily: 'TagRegular',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: appPrimaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "New Delhi, India",
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Bold',
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.expand_more,
                      color: textTheme.bodySmall?.color,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              radius: 22,
              backgroundColor: isDarkMode
                  ? Colors.white.withAlpha(20)
                  : appLightColor.withAlpha(200),
              child: const Icon(
                Icons.person_outline,
                color: appPrimaryColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final bool isDarkMode;

  HomeSearchBarDelegate({required this.isDarkMode});

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final textTheme = Theme.of(context).textTheme;
    final Color scaffoldBg = isDarkMode ? appDarkColor : Colors.grey[50]!;
    final Color inputColor = isDarkMode
        ? Colors.white.withAlpha(13)
        : Colors.white;
    final Color shadowColor = isDarkMode
        ? Colors.black.withAlpha(50)
        : Colors.grey.withAlpha(100);
    final Color borderColor = isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    final double elevation = (shrinkOffset > maxExtent - minExtent) ? 4.0 : 0.0;
    final Color currentShadowColor = (elevation > 0)
        ? shadowColor
        : Colors.transparent;

    return Material(
      color: scaffoldBg,
      elevation: elevation,
      shadowColor: currentShadowColor,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search Madarsa, Masjid...",
            hintStyle: textTheme.bodyMedium?.copyWith(
              fontFamily: 'Regular',
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 24),
            filled: true,
            fillColor: inputColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: appPrimaryColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80.0;

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class LiveClockSection extends StatefulWidget {
  const LiveClockSection({super.key});

  @override
  State<LiveClockSection> createState() => _LiveClockSectionState();
}

class _LiveClockSectionState extends State<LiveClockSection> {
  late String _currentTime;
  late String _currentDay;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer t) => _updateTime(),
    );
  }

  void _updateTime() {
    final now = DateTime.now();
    final String formattedTime = DateFormat('h:mm:ss a').format(now);
    final String formattedDay = DateFormat('EEEE, d MMMM').format(now);
    if (mounted) {
      setState(() {
        _currentTime = formattedTime;
        _currentDay = formattedDay;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentTime,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontFamily: 'Bold',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentDay,
                  style: textTheme.bodySmall?.copyWith(
                    fontFamily: 'TagRegular',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  color: appSecondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "28°C", // Fake weather
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontFamily: 'Bold',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  final List<Map<String, dynamic>> categories = const [
    {"name": "Masjids", "icon": Icons.mosque_outlined},
    {"name": "Madarsas", "icon": Icons.school_outlined},
    {"name": "Donate", "icon": Icons.volunteer_activism_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((category) {
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withAlpha(15) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
                child: Icon(category["icon"], color: appPrimaryColor, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                category["name"],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'Regular',
                  fontSize: 13,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class NearbyMasjidList extends StatefulWidget {
  const NearbyMasjidList({super.key});

  @override
  State<NearbyMasjidList> createState() => _NearbyMasjidListState();
}

class _NearbyMasjidListState extends State<NearbyMasjidList> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: 5000,
    );
    _currentPage = 5000;

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 10000,
        itemBuilder: (context, index) {
          final int realIndex = index % nearbyMasjids.length;
          return NearbyListItem(
            place: nearbyMasjids[realIndex],
            label: "Mosque",
          );
        },
      ),
    );
  }
}

class NearbyMadarsaList extends StatefulWidget {
  const NearbyMadarsaList({super.key});

  @override
  State<NearbyMadarsaList> createState() => _NearbyMadarsaListState();
}

class _NearbyMadarsaListState extends State<NearbyMadarsaList> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: 5000,
    );
    _currentPage = 5000;

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (mounted) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 10000,
        itemBuilder: (context, index) {
          final int realIndex = index % nearbyMadarsas.length;
          return NearbyListItem(
            place: nearbyMadarsas[realIndex],
            label: "Madarsa",
          );
        },
      ),
    );
  }
}


class NearbyListItem extends StatelessWidget {
  final Place place;
  final String label;

  const NearbyListItem({super.key, required this.place, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              place.imageUrl,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, color: Colors.grey[500]),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: appPrimaryColor,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Bold',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.location,
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: 'TagRegular',
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'Bold',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendedMadarsasList extends StatelessWidget {
  final AnimationController animationController;
  const RecommendedMadarsasList({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topMadarsas.length,
        itemBuilder: (context, index) {
          final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Interval(
                (0.1 * index) / topMadarsas.length,
                0.5 + (0.1 * index) / topMadarsas.length,
                curve: Curves.easeOutCubic,
              ),
            ),
          );

          return RecommendedListItem(
            place: topMadarsas[index],
            animation: animation,
          );
        },
      ),
    );
  }
}

class RecommendedListItem extends StatelessWidget {
  final Place place;
  final Animation<double> animation;
  const RecommendedListItem({
    super.key,
    required this.place,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? appDarkColor : Colors.white;
    final Color borderColor = isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[200]!;

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          place.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 120,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[500],
                                ),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: appPrimaryColor,
                                  value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Madarsa",
                                style: textTheme.bodySmall?.copyWith(
                                  fontFamily: 'Bold',
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Bold',
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey[500],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                place.location,
                                style: textTheme.bodySmall?.copyWith(
                                  fontFamily: 'TagRegular',
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: appSecondaryColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: appSecondaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                place.rating.toString(),
                                style: textTheme.bodySmall?.copyWith(
                                  fontFamily: 'Bold',
                                  color: appSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}