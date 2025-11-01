import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madarsago/login_screen.dart';
import 'package:madarsago/main.dart';
import 'package:madarsago/profile_provider.dart';
import 'add_listing_items.dart';
import 'admin_panel.dart';
import 'become_a_cont.dart';
import 'edit_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDarkMode ? appDarkColor : Colors.grey[50]!;
    final Color cardColor = isDarkMode ? appDarkColor : Colors.white;
    final Color shadowColor = isDarkMode
        ? Colors.black.withAlpha(50)
        : Colors.grey.withAlpha(100);

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final userData = ref.watch(userDataProvider);

    String userRole = "viewer";
    if (userData.hasValue && userData.value?.data() != null) {
      userRole =
          (userData.value!.data() as Map<String, dynamic>)['role'] ?? 'viewer';
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 18,
            fontFamily: 'Bold',
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textTheme.headlineMedium?.color),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 16.0,
          bottom: 16.0 + bottomPadding,
        ),
        children: [
          const ProfileHeader(),
          const SizedBox(height: 24),
          _buildSectionCard(cardColor, shadowColor, [
            ProfileListItem(
              icon: Icons.edit_outlined,
              iconColor: Colors.blueAccent,
              title: "Edit Profile",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            const ProfileListDivider(),
            ProfileListItem(
              icon: Icons.bookmark_border,
              iconColor: appPrimaryColor,
              title: "My Saved Items",
              onTap: () {},
            ),
            const ProfileListDivider(),
            ProfileListItem(
              icon: Icons.volunteer_activism_outlined,
              iconColor: appSecondaryColor,
              title: "My Donations",
              onTap: () {},
            ),
            if (userRole == 'viewer') ...[
              const ProfileListDivider(),
              ProfileListItem(
                icon: Icons.add_business_outlined,
                iconColor: Colors.green,
                title: "Become a Contributor",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ContributorFormScreen(),
                    ),
                  );
                },
              ),
            ],
          ]),

          if (userRole == 'contributor' || userRole == 'admin') ...[
            const SizedBox(height: 24),
            _buildSectionTitle(textTheme, "CONTRIBUTOR"),
            const SizedBox(height: 12),
            _buildSectionCard(cardColor, shadowColor, [
              ProfileListItem(
                icon: Icons.add_location_alt_outlined,
                iconColor: appPrimaryColor,
                title: "Add New Listing",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddListingScreen(),
                    ),
                  );
                },
              ),
            ]),
          ],

          if (userRole == 'admin') ...[
            const SizedBox(height: 24),
            _buildSectionTitle(textTheme, "ADMIN"),
            const SizedBox(height: 12),
            _buildSectionCard(cardColor, shadowColor, [
              ProfileListItem(
                icon: Icons.admin_panel_settings_outlined,
                iconColor: Colors.blue,
                title: "Admin Panel",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminPanelScreen(),
                    ),
                  );
                },
              ),
            ]),
          ],
          const SizedBox(height: 24),
          _buildSectionTitle(textTheme, "Settings"),
          const SizedBox(height: 12),
          _buildSectionCard(cardColor, shadowColor, [
            ProfileThemeSwitch(),
            const ProfileListDivider(),
            ProfileListItem(
              icon: Icons.notifications_none,
              iconColor: appAccentColor,
              title: "Notifications",
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode
                  ? Colors.red.withAlpha(50)
                  : Colors.red[50],
              foregroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              await ref.read(firebaseAuthProvider).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(
              "Logout",
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Bold',
                fontSize: 13,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    Color cardColor,
    Color shadowColor,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSectionTitle(TextTheme textTheme, String title) {
    return Text(
      title.toUpperCase(),
      style: textTheme.bodySmall?.copyWith(
        fontSize: 11,
        fontFamily: 'Bold',
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }
}

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final userData = ref.watch(userDataProvider);

    String displayName = "Welcome";
    String displaySub = "Guest User";
    String? photoUrl;

    if (userData.hasValue && userData.value?.data() != null) {
      final data = userData.value!.data() as Map<String, dynamic>;
      displayName = data['fullName'] ?? "Welcome";
      displaySub = data['phoneNumber'] ?? "User";
      photoUrl = data['photoUrl'];
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: appPrimaryColor.withAlpha(30),
          backgroundImage: (photoUrl != null) ? NetworkImage(photoUrl) : null,
          child: (photoUrl == null)
              ? const Icon(Icons.person, color: appPrimaryColor, size: 32)
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: textTheme.headlineMedium?.copyWith(
                fontFamily: 'Bold',
                fontSize: 18,
              ),
            ),
            Text(
              displaySub,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Regular',
                fontSize: 14.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Bold',
                    fontSize: 14.5,
                  ),
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileThemeSwitch extends ConsumerWidget {
  const ProfileThemeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appAccentColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: appAccentColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Dark Mode",
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'Bold',
                fontSize: 14.5,
              ),
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              ref
                  .read(themeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            activeColor: appPrimaryColor,
          ),
        ],
      ),
    );
  }
}

class ProfileListDivider extends StatelessWidget {
  const ProfileListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 72.0, right: 16.0),
      child: Divider(
        height: 1,
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
    );
  }
}
