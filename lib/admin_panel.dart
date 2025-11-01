import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madarsago/main.dart';
import 'package:madarsago/profile_provider.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDarkMode ? appDarkColor : Colors.grey[50]!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Admin Panel",
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: appPrimaryColor,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: appPrimaryColor,
          tabs: const [
            Tab(
              icon: Icon(Icons.person_add_alt_1_outlined),
              text: "Applications",
            ),
            Tab(
              icon: Icon(Icons.domain_verification_outlined),
              text: "Listings",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsList(context, ref),
          _buildListingsList(context, ref),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(pendingApplicationsProvider);
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return applicationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: ${err.toString()}")),
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return _buildEmptyState(
            textTheme,
            "All Caught Up!",
            "There are no pending applications to review.",
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return ApplicationSummaryCard(
              docId: doc.id,
              data: data,
              isDarkMode: isDarkMode,
            );
          },
        );
      },
    );
  }

  Widget _buildListingsList(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(pendingListingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return listingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: ${err.toString()}")),
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return _buildEmptyState(
            textTheme,
            "No Pending Listings",
            "There are no new listings to verify right now.",
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return ListingSummaryCard(
              docId: doc.id,
              data: data,
              isDarkMode: isDarkMode,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: textTheme.headlineMedium?.copyWith(
                fontFamily: 'Bold',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'TagRegular',
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Application Card ---
class ApplicationSummaryCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const ApplicationSummaryCard({
    super.key,
    required this.docId,
    required this.data,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color cardColor = isDarkMode ? appDarkColor : Colors.white;
    final Color shadowColor = isDarkMode
        ? Colors.black.withAlpha(50)
        : Colors.grey.withAlpha(100);

    return Card(
      elevation: 4,
      shadowColor: shadowColor,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) =>
                  ApplicationDetailScreen(docId: docId, data: data),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['fullName'] ?? 'N/A',
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Bold',
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['affiliation'] ?? 'No Affiliation',
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Regular',
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data['roleAtAffiliation'] ?? 'No Role',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Tap to view details",
                  style: textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 11.5,
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

// --- Listing Card ---
class ListingSummaryCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const ListingSummaryCard({
    super.key,
    required this.docId,
    required this.data,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color cardColor = isDarkMode ? appDarkColor : Colors.white;
    final Color shadowColor = isDarkMode
        ? Colors.black.withAlpha(50)
        : Colors.grey.withAlpha(100);

    return Card(
      elevation: 4,
      shadowColor: shadowColor,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ListingDetailScreen(docId: docId, data: data),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'] ?? 'N/A',
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Bold',
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['address'] ?? 'No Address',
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Regular',
                  fontSize: 14.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Tap to verify",
                  style: textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 11.5,
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

// --- Application Detail Screen ---
class ApplicationDetailScreen extends ConsumerStatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const ApplicationDetailScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  ConsumerState<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState
    extends ConsumerState<ApplicationDetailScreen> {
  bool _isLoading = false;

  Future<void> _onAccept() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = ref.read(firestoreProvider);
      final batch = firestore.batch();

      final appRef = firestore.collection('applications').doc(widget.docId);
      final userRef = firestore.collection('users').doc(widget.docId);

      batch.update(appRef, {'status': 'accepted'});
      batch.update(userRef, {'role': 'contributor'});

      await batch.commit();

      if (mounted) {
        Navigator.of(context).pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("User approved as Contributor."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Error accepting application: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onReject() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = ref.read(firestoreProvider);
      final batch = firestore.batch();

      final appRef = firestore.collection('applications').doc(widget.docId);
      batch.update(appRef, {'status': 'rejected'});
      await batch.commit();

      if (mounted) {
        Navigator.of(context).pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Application rejected."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Error rejecting application: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDarkMode ? appDarkColor : Colors.grey[50]!;
    final Color cardColor = isDarkMode ? appDarkColor : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Application Details",
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildDetailCard(
                  context,
                  cardColor,
                  textTheme,
                  "Applicant Information",
                  [
                    _buildInfoRow(
                      textTheme,
                      Icons.person_outline,
                      "Full Name",
                      widget.data['fullName'] ?? "N/A",
                    ),
                    _buildInfoRow(
                      textTheme,
                      Icons.phone_outlined,
                      "Phone Number",
                      widget.data['phoneNumber'] ?? "N/A",
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailCard(
                  context,
                  cardColor,
                  textTheme,
                  "Affiliation Details",
                  [
                    _buildInfoRow(
                      textTheme,
                      Icons.mosque_outlined,
                      "Masjid / Madarsa",
                      widget.data['affiliation'] ?? "N/A",
                    ),
                    _buildInfoRow(
                      textTheme,
                      Icons.work_outline,
                      "Role at Affiliation",
                      widget.data['roleAtAffiliation'] ?? "N/A",
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailCard(
                  context,
                  cardColor,
                  textTheme,
                  "Reason for Applying",
                  [
                    _buildInfoRow(
                      textTheme,
                      Icons.note_alt_outlined,
                      "Reason",
                      widget.data['reason'] ?? "N/A",
                      isReason: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close_rounded),
                        label: const Text("Reject"),
                        onPressed: _isLoading ? null : _onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          side: BorderSide(color: Colors.red[700]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Bold',
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded),
                        label: const Text("Accept"),
                        onPressed: _isLoading ? null : _onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Bold',
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    Color cardColor,
    TextTheme textTheme,
    String title,
    List<Widget> children,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color shadowColor = isDarkMode
        ? Colors.black.withAlpha(50)
        : Colors.grey.withAlpha(100);

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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontFamily: 'Bold',
              fontSize: 17,
            ),
          ),
          const Divider(height: 30, thickness: 1),
          ...children
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: child,
                ),
              )
              .toList(),
          if (children.isNotEmpty) const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    TextTheme textTheme,
    IconData icon,
    String title,
    String value, {
    bool isReason = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Regular',
                  fontSize: 15,
                  height: isReason ? 1.4 : 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- YAHAN SE NAYI CLASS ADD KI GAYI HAI ---

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const ListingDetailScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  bool _isLoading = false;

  Future<void> _onVerify() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = ref.read(firestoreProvider);
      await firestore.collection('listings').doc(widget.docId).update({
        'isVerified': true,
      });

      if (mounted) {
        Navigator.of(context).pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Listing has been verified and is now public."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Error verifying listing: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onReject() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = ref.read(firestoreProvider);
      // Reject ke liye, hum status field add kar sakte hain ya delete kar sakte hain
      // Abhi ke liye, hum ise delete kar dete hain
      await firestore.collection('listings').doc(widget.docId).delete();

      if (mounted) {
        Navigator.of(context).pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Listing rejected and deleted."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Error rejecting listing: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDarkMode ? appDarkColor : Colors.grey[50]!;
    final Color cardColor = isDarkMode ? appDarkColor : Colors.white;

    final List<String> images = List<String>.from(
      widget.data['imageUrls'] ?? [],
    );
    final List<String> facilities = List<String>.from(
      widget.data['facilities'] ?? [],
    );

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Verify Listing",
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                if (images.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                _buildDetailCard(
                  context,
                  cardColor,
                  textTheme,
                  widget.data['name'] ?? "N/A",
                  [
                    _buildInfoRow(
                      textTheme,
                      Icons.location_on_outlined,
                      "Address",
                      widget.data['address'] ?? "N/A",
                      isReason: true,
                    ),
                    _buildInfoRow(
                      textTheme,
                      Icons.phone_outlined,
                      "Contact",
                      widget.data['contactNumber'] ?? "N/A",
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailCard(context, cardColor, textTheme, "Description", [
                  _buildInfoRow(
                    textTheme,
                    Icons.info_outline,
                    "Details",
                    widget.data['description'] ?? "N/A",
                    isReason: true,
                  ),
                ]),
                const SizedBox(height: 24),
                if (facilities.isNotEmpty)
                  _buildDetailCard(
                    context,
                    cardColor,
                    textTheme,
                    "Facilities",
                    [
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: facilities
                            .map((f) => Chip(label: Text(f)))
                            .toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close_rounded),
                        label: const Text("Reject"),
                        onPressed: _isLoading ? null : _onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          side: BorderSide(color: Colors.red[700]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Bold',
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded),
                        label: const Text("Verify"),
                        onPressed: _isLoading ? null : _onVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Bold',
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    Color cardColor,
    TextTheme textTheme,
    String title,
    List<Widget> children,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color shadowColor = isDarkMode
        ? Colors.black.withAlpha(50)
        : Colors.grey.withAlpha(100);

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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontFamily: 'Bold',
              fontSize: 17,
            ),
          ),
          const Divider(height: 30, thickness: 1),
          ...children
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: child,
                ),
              )
              .toList(),
          if (children.isNotEmpty) const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    TextTheme textTheme,
    IconData icon,
    String title,
    String value, {
    bool isReason = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Regular',
                  fontSize: 15,
                  height: isReason ? 1.4 : 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
