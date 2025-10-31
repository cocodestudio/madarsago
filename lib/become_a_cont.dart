import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madarsago/main.dart';
import 'package:madarsago/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContributorFormScreen extends ConsumerStatefulWidget {
  const ContributorFormScreen({super.key});

  @override
  ConsumerState<ContributorFormScreen> createState() =>
      _ContributorFormScreenState();
}

class _ContributorFormScreenState extends ConsumerState<ContributorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _affiliationController;
  late final TextEditingController _roleController;
  late final TextEditingController _reasonController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _affiliationController = TextEditingController();
    _roleController = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _affiliationController.dispose();
    _roleController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withAlpha(30),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Application Submitted",
                style: textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Bold',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Thank you for applying. We will review your application and update your role soon.",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'TagRegular',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }
      final firestore = ref.read(firestoreProvider);

      await firestore.collection('applications').doc(user.uid).set({
        'userId': user.uid,
        'phoneNumber': user.phoneNumber,
        'fullName': _nameController.text,
        'affiliation': _affiliationController.text,
        'roleAtAffiliation': _roleController.text,
        'reason': _reasonController.text,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSuccessDialog(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Submission failed: ${e.toString()}"),
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

    final appStatus = ref.watch(applicationStatusProvider);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: appStatus.when(
        loading: () => Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            title: Text(
              "Loading Status...",
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
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            title: Text(
              "Error",
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
          body: Center(child: Text("Error: ${err.toString()}")),
        ),
        data: (snapshot) {
          final bool isPending =
              snapshot != null &&
              snapshot.exists &&
              (snapshot.data() as Map<String, dynamic>)['status'] == 'pending';

          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: AppBar(
              title: Text(
                isPending ? "Application Status" : "Apply for Contributor",
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
            body: isPending
                ? _buildPendingScreen(context)
                : _buildFormScreen(context),
          );
        },
      ),
    );
  }

  Widget _buildPendingScreen(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withAlpha(30),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Colors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Application Pending",
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontFamily: 'Bold',
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your application is currently under review. We will notify you once it's approved.",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'TagRegular',
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormScreen(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color inputFillColor = isDarkMode
        ? Colors.white.withAlpha(13)
        : Colors.black.withAlpha(10);
    final Color borderColor = isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              "Tell us about yourself",
              style: textTheme.headlineMedium?.copyWith(
                fontFamily: 'Bold',
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "To maintain the quality and trust of our data, we manually approve all contributors.",
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: 'TagRegular',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextFormField(
              controller: _nameController,
              labelText: "Full Name",
              icon: Icons.person_outline,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter your full name";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextFormField(
              controller: _affiliationController,
              labelText: "Associated Masjid / Madarsa",
              icon: Icons.mosque_outlined,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter your affiliation";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextFormField(
              controller: _roleController,
              labelText: "Your Role (e.g., Imam, Teacher)",
              icon: Icons.work_outline,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter your role";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextFormField(
              controller: _reasonController,
              labelText: "Reason for applying",
              icon: Icons.note_alt_outlined,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please provide a reason";
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: appPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Bold',
                  fontSize: 16,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text("Submit Application"),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required Color inputFillColor,
    required Color borderColor,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: appPrimaryColor, width: 2),
        ),
      ),
    );
  }
}
