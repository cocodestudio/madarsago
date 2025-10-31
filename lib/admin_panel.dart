import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madarsago/main.dart';
import 'package:madarsago/profile_provider.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = isDarkMode ? appDarkColor : Colors.grey[50]!;

    final applicationsAsync = ref.watch(pendingApplicationsProvider);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Admin Panel",
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontFamily: 'Bold',
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textTheme.headlineMedium?.color),
      ),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: ${err.toString()}")),
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
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
                      "All Caught Up!",
                      style: textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Bold',
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "There are no pending applications to review.",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'TagRegular',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // New compact card view
              return ApplicationSummaryCard(
                docId: doc.id,
                data: data,
                isDarkMode: isDarkMode,
              );
            },
          );
        },
      ),
    );
  }
}

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
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['affiliation'] ?? 'No Affiliation',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Regular'),
              ),
              const SizedBox(height: 4),
              Text(
                data['roleAtAffiliation'] ?? 'No Role',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Tap to view details",
                  style: textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
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

      // Application status update
      batch.update(appRef, {'status': 'accepted'});
      // User role update
      batch.update(userRef, {'role': 'contributor'});

      await batch.commit();

      if (mounted) {
        Navigator.of(context).pop(); // Go back to Admin Panel
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("User approved as Contributor."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Error accepting application: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
      final userRef = firestore.collection('users').doc(widget.docId);
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
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Error rejecting application: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
            fontSize: 20,
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
                  cardColor,
                  textTheme,
                  "Applicant Information",
                  [
                    _buildInfoRow(
                      textTheme,
                      Icons.person_outline,
                      "Full Name",
                      widget.data['fullName'],
                    ),
                    _buildInfoRow(
                      textTheme,
                      Icons.phone_outlined,
                      "Phone Number",
                      widget.data['phoneNumber'],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailCard(cardColor, textTheme, "Affiliation Details", [
                  _buildInfoRow(
                    textTheme,
                    Icons.mosque_outlined,
                    "Masjid / Madarsa",
                    widget.data['affiliation'],
                  ),
                  _buildInfoRow(
                    textTheme,
                    Icons.work_outline,
                    "Role at Affiliation",
                    widget.data['roleAtAffiliation'],
                  ),
                ]),
                const SizedBox(height: 24),
                _buildDetailCard(cardColor, textTheme, "Reason for Applying", [
                  _buildInfoRow(
                    textTheme,
                    Icons.note_alt_outlined,
                    "Reason",
                    widget.data['reason'],
                    isReason: true,
                  ),
                ]),
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
              fontSize: 18,
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
          if (children.isNotEmpty)
            const SizedBox(height: 8), // Padding after last item
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
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Regular',
                  fontSize: 16,
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
