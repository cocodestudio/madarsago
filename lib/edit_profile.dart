import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madarsago/main.dart';
import 'package:madarsago/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  String _gender = 'male';
  String? _profileImageUrl;
  XFile? _pickedImage;
  bool _didDeleteImage = false;
  bool _isLoading = false;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadInitialData();
  }

  void _loadInitialData() {
    final userData = ref.read(userDataProvider);
    if (userData.hasValue && userData.value?.data() != null) {
      final data = userData.value!.data() as Map<String, dynamic>;
      _nameController.text = data['fullName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _gender = data['gender'] ?? 'male';
      _profileImageUrl = data['photoUrl'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _showImagePickerSheet() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme; // CHANGED: Added textTheme
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? appDarkColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              // CHANGED: Applied style
              title: Text(
                "Take Photo",
                style: textTheme.bodyMedium?.copyWith(fontSize: 14.5),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              // CHANGED: Applied style
              title: Text(
                "Choose from Gallery",
                style: textTheme.bodyMedium?.copyWith(fontSize: 14.5),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImageUrl != null || _pickedImage != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red[700]),
                // CHANGED: Applied style
                title: Text(
                  "Delete Photo",
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.red[700],
                    fontSize: 14.5,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _pickedImage = null;
                    _profileImageUrl = null;
                    _didDeleteImage = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (image != null) {
        setState(() {
          _pickedImage = image;
          _didDeleteImage = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) throw Exception("User not found");

      String? finalPhotoUrl = _profileImageUrl;

      if (_didDeleteImage) {
        finalPhotoUrl = null;
        try {
          await ref
              .read(storageProvider)
              .ref('users/${user.uid}/profile.jpg')
              .delete();
        } catch (e) {
          // Ignore if file doesn't exist
        }
      } else if (_pickedImage != null) {
        final storageRef = ref
            .read(storageProvider)
            .ref('users/${user.uid}/profile.jpg');
        final uploadTask = await storageRef.putFile(File(_pickedImage!.path));
        finalPhotoUrl = await uploadTask.ref.getDownloadURL();
      }

      await ref.read(firestoreProvider).collection('users').doc(user.uid).set({
        'fullName': _nameController.text,
        'email': _emailController.text,
        'gender': _gender,
        'photoUrl': finalPhotoUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: ${e.toString()}"),
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
    final Color inputFillColor = isDarkMode
        ? Colors.white.withAlpha(13)
        : Colors.black.withAlpha(10);
    final Color borderColor = isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    ImageProvider? backgroundImage;
    if (_pickedImage != null) {
      backgroundImage = FileImage(File(_pickedImage!.path));
    } else if (_profileImageUrl != null) {
      backgroundImage = NetworkImage(_profileImageUrl!);
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 18, // CHANGED: 20 se 18
            fontFamily: 'Bold',
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textTheme.headlineMedium?.color),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: appPrimaryColor.withAlpha(30),
                      backgroundImage: backgroundImage,
                      child: backgroundImage == null
                          ? const Icon(
                              Icons.person,
                              color: appPrimaryColor,
                              size: 60,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePickerSheet,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: appPrimaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: scaffoldBg, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                controller: _emailController,
                labelText: "Email Address",
                icon: Icons.email_outlined,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !value.contains('@')) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                "Gender",
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Bold',
                  fontSize: 15, // CHANGED: 16 se 15
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: inputFillColor,
                  foregroundColor: isDarkMode ? Colors.white70 : Colors.black54,
                  selectedBackgroundColor: appPrimaryColor,
                  selectedForegroundColor: Colors.white,
                  // CHANGED: Added textStyle
                  textStyle: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Bold',
                    fontSize: 13.5,
                  ),
                ),
                segments: const [
                  ButtonSegment<String>(
                    value: 'male',
                    label: Text('Male'),
                    icon: Icon(Icons.male),
                  ),
                  ButtonSegment<String>(
                    value: 'female',
                    label: Text('Female'),
                    icon: Icon(Icons.female),
                  ),
                  ButtonSegment<String>(
                    value: 'other',
                    label: Text('Other'),
                    icon: Icon(Icons.person_outline),
                  ),
                ],
                selected: {_gender},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _gender = newSelection.first;
                  });
                },
                multiSelectionEnabled: false,
                emptySelectionAllowed: false,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  textStyle: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Bold',
                    fontSize: 15,
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
                    : const Text("Save Changes"),
              ),
            ],
          ),
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
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    // CHANGED: Added textTheme
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      // CHANGED: Added style
      style: textTheme.bodyMedium?.copyWith(fontSize: 14.5),
      decoration: InputDecoration(
        labelText: labelText,
        // CHANGED: Added labelStyle
        labelStyle: textTheme.bodyMedium?.copyWith(fontSize: 14.5),
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
