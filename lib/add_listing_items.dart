import 'dart:async';
import 'dart:io';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madarsago/main.dart';
import 'package:madarsago/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  Set<String> _listingType = {'masjid'};
  List<XFile> _exteriorImages = [];
  List<XFile> _interiorImages = [];
  List<XFile> _listingDocuments = [];
  List<XFile> _userDocuments = [];

  bool _isLoading = false;
  final _imagePicker = ImagePicker();

  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  Set<Marker> _markers = {};
  bool _isMapLoading = true;
  final LatLng _defaultLocation = const LatLng(28.6139, 77.2090);

  final Map<String, String> _allFacilities = {
    'wudu': "Wudu Area",
    'parking': "Parking",
    'women': "Women's Area",
    'wheelchair': "Wheelchair Access",
    'maktab': "Maktab / Classes",
    'hifz': "Hifz Program",
    'ac': "Air Conditioned",
    'library': "Library",
    'hostel': "Hostel Facility",
  };
  Set<String> _selectedFacilities = {};
  bool _isFetchingAddress = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndMoveCamera(isInitial: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndMoveCamera({
    bool isInitial = false,
  }) async {
    setState(() {
      _isMapLoading = true;
    });
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (isInitial) _onMapTapped(_defaultLocation);
      setState(() {
        _isMapLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (isInitial) _onMapTapped(_defaultLocation);
        setState(() {
          _isMapLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (isInitial) _onMapTapped(_defaultLocation);
      setState(() {
        _isMapLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      if (isInitial) {
        _onMapTapped(currentLocation);
      }
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 16.0),
      );
    } catch (e) {
      if (isInitial) _onMapTapped(_defaultLocation);
    } finally {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    }
  }

  Future<void> _onMapTapped(LatLng location) async {
    setState(() {
      _pickedLocation = location;
      _markers = {
        Marker(markerId: const MarkerId('pickedLocation'), position: location),
      };
    });
  }

  Future<void> _openFullScreenMap() async {
    FocusScope.of(context).unfocus();
    final LatLng? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLocation: _pickedLocation ?? _defaultLocation,
        ),
      ),
    );

    if (result != null) {
      _onMapTapped(result);
      _mapController?.animateCamera(CameraUpdate.newLatLng(result));
    }
  }

  Future<void> _fetchAndFillAddress() async {
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please tap on the map to select a location first."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isFetchingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _pickedLocation!.latitude,
        _pickedLocation!.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.name ?? ''}, ${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}";
        _addressController.text = address
            .replaceAll(RegExp(r', , '), ', ')
            .replaceAll(RegExp(r'^, '), '');
      }
    } catch (e) {
      _addressController.text =
          "Could not fetch address. Please enter manually.";
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingAddress = false;
        });
      }
    }
  }

  Future<void> _pickImages(List<XFile> imageList, int maxLimit) async {
    final int remainingSlots = maxLimit - imageList.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You can only upload a maximum of $maxLimit images."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (images.isEmpty) return;

      int addedCount = 0;
      for (var image in images) {
        if (imageList.length < maxLimit) {
          imageList.add(image);
          addedCount++;
        } else {
          break;
        }
      }

      setState(() {});

      if (addedCount < images.length) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Limit reached. Only ${images.length - addedCount} images were discarded.",
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Image picking failed: $e")));
      }
    }
  }

  Future<List<String>> _uploadImages(
    String listingId,
    List<XFile> imageList,
    String folderName,
  ) async {
    List<String> imageUrls = [];
    final storageRef = ref.read(storageProvider).ref();
    final baseTimestamp = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < imageList.length; i++) {
      final imageFile = imageList[i];
      final fileName = '${baseTimestamp}_$i.jpg';
      final uploadRef = storageRef.child(
        "listings/$listingId/$folderName/$fileName",
      );
      try {
        final uploadTask = await uploadRef.putFile(
          File(imageFile.path),
          SettableMetadata(contentType: "image/jpeg"),
        );
        final url = await uploadTask.ref.getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
        // Handle image upload error
      }
    }
    return imageUrls;
  }

  void _showSuccessDialog(BuildContext context, bool isVerified) {
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
                "Listing Submitted",
                style: textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Bold',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isVerified
                    ? "Your listing has been approved and is now public."
                    : "Your new listing is pending verification. Thank you for contributing!",
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
                  elevation: 0,
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

  Future<void> _submitListing() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a location on the map."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_exteriorImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one Exterior Image."),
          backgroundColor: Colors.red,
        ),
      );
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

      final userData = await ref.read(userDataProvider.future);
      final userRole =
          (userData?.data() as Map<String, dynamic>?)?['role'] ?? 'viewer';
      final bool isAdmin = (userRole == 'admin');

      final newListingRef = firestore.collection("listings").doc();

      final geoHasher = GeoHasher();
      final String geohashString = geoHasher.encode(
        _pickedLocation!.latitude,
        _pickedLocation!.longitude,
        precision: 7,
      );

      final exteriorUrls = await _uploadImages(
        newListingRef.id,
        _exteriorImages,
        "exterior",
      );
      final interiorUrls = await _uploadImages(
        newListingRef.id,
        _interiorImages,
        "interior",
      );
      final listingDocUrls = await _uploadImages(
        newListingRef.id,
        _listingDocuments,
        "listing_docs",
      );
      final userDocUrls = await _uploadImages(
        newListingRef.id,
        _userDocuments,
        "user_docs",
      );

      await newListingRef.set({
        'name': _nameController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
        'contactNumber': _contactController.text,
        'type': _listingType.first,
        'imageUrls': exteriorUrls,
        'interiorImageUrls': interiorUrls,
        'listingDocumentUrls': listingDocUrls,
        'userDocumentUrls': userDocUrls,
        'facilities': _selectedFacilities.toList(),
        'location': GeoPoint(
          _pickedLocation!.latitude,
          _pickedLocation!.longitude,
        ),
        'geohash': geohashString,
        'postedBy': user.uid,
        'isVerified': isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
        'rating': 0.0,
        'totalRatings': 0,
      });

      if (mounted) {
        _showSuccessDialog(context, isAdmin);
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
    final Color inputFillColor = isDarkMode
        ? Colors.white.withAlpha(13)
        : Colors.black.withAlpha(10);
    final Color borderColor = isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Add New Listing",
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildSectionTitle(textTheme, "Listing Type"),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: inputFillColor,
                  foregroundColor: isDarkMode ? Colors.white70 : Colors.black54,
                  selectedBackgroundColor: appPrimaryColor,
                  selectedForegroundColor: Colors.white,
                ),
                segments: const [
                  ButtonSegment<String>(
                    value: 'masjid',
                    label: Text('Masjid'),
                    icon: Icon(Icons.mosque_outlined),
                  ),
                  ButtonSegment<String>(
                    value: 'madarsa',
                    label: Text('Madarsa'),
                    icon: Icon(Icons.school_outlined),
                  ),
                ],
                selected: _listingType,
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _listingType = newSelection;
                  });
                },
                multiSelectionEnabled: false,
                emptySelectionAllowed: false,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(textTheme, "Basic Details"),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _nameController,
                labelText: "Name of Masjid / Madarsa",
                borderColor: borderColor,
                inputFillColor: inputFillColor,
                validator: (val) =>
                    (val == null || val.isEmpty) ? "Please enter a name" : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(textTheme, "Select Location"),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _openFullScreenMap,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: _pickedLocation ?? _defaultLocation,
                            zoom: 11.0,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          markers: _markers,
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          onTap: (_) => _openFullScreenMap(),
                        ),
                        if (_isMapLoading)
                          Container(
                            color: Colors.black.withAlpha(128),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: appPrimaryColor,
                              ),
                            ),
                          ),
                        Container(
                          color: Colors.black.withAlpha(50),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app_outlined,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Tap to select location",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _addressController,
                labelText: "Full Address",
                hintText: "Enter manually or auto-fetch from map",
                maxLines: 3,
                borderColor: borderColor,
                inputFillColor: inputFillColor,
                validator: (val) => (val == null || val.isEmpty)
                    ? "Please enter an address"
                    : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _isFetchingAddress
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton.icon(
                        onPressed: _fetchAndFillAddress,
                        icon: const Icon(
                          Icons.my_location,
                          size: 18,
                          color: appPrimaryColor,
                        ),
                        label: Text(
                          "Auto-fetch from map",
                          style: textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Bold',
                            color: appPrimaryColor,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _contactController,
                labelText: "Contact Number (e.g., +91...)",
                borderColor: borderColor,
                inputFillColor: inputFillColor,
                keyboardType: TextInputType.phone,
                validator: (val) => (val == null || val.isEmpty)
                    ? "Please enter a contact number"
                    : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(textTheme, "Facilities"),
              const SizedBox(height: 12),
              _buildFacilitiesChips(inputFillColor),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: _descriptionController,
                labelText: "Description (Timings, Courses, etc.)",
                maxLines: 5,
                borderColor: borderColor,
                inputFillColor: inputFillColor,
                validator: (val) => (val == null || val.isEmpty)
                    ? "Please enter a description"
                    : null,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(textTheme, "Exterior Images (Required)"),
              _buildRemarkText(
                textTheme,
                "Max 10 images. First image will be the cover.",
              ),
              const SizedBox(height: 12),
              _buildImageUploader(
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                maxLimit: 10,
                imageList: _exteriorImages,
                onAdd: () => _pickImages(_exteriorImages, 10),
                onRemove: (index) =>
                    setState(() => _exteriorImages.removeAt(index)),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(textTheme, "Interior Images"),
              _buildRemarkText(textTheme, "Max 10 images."),
              const SizedBox(height: 12),
              _buildImageUploader(
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                maxLimit: 10,
                imageList: _interiorImages,
                onAdd: () => _pickImages(_interiorImages, 10),
                onRemove: (index) =>
                    setState(() => _interiorImages.removeAt(index)),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(textTheme, "Listing Documents"),
              _buildRemarkText(
                textTheme,
                "e.g., Ownership docs, Electricity bill. (Max 5)",
              ),
              const SizedBox(height: 12),
              _buildImageUploader(
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                maxLimit: 5,
                imageList: _listingDocuments,
                onAdd: () => _pickImages(_listingDocuments, 5),
                onRemove: (index) =>
                    setState(() => _listingDocuments.removeAt(index)),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(textTheme, "Contributor's Documents"),
              _buildRemarkText(
                textTheme,
                "e.g., Your Aadhar card, PAN card. (Max 3)",
              ),
              const SizedBox(height: 12),
              _buildImageUploader(
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                maxLimit: 3,
                imageList: _userDocuments,
                onAdd: () => _pickImages(_userDocuments, 3),
                onRemove: (index) =>
                    setState(() => _userDocuments.removeAt(index)),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitListing,
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
                    fontSize: 14,
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
                    : const Text("Submit for Verification"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitiesChips(Color inputFillColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _allFacilities.keys.map((key) {
          final isSelected = _selectedFacilities.contains(key);
          return ChoiceChip(
            label: Text(_allFacilities[key]!),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedFacilities.add(key);
                } else {
                  _selectedFacilities.remove(key);
                }
              });
            },
            selectedColor: appPrimaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : null,
              fontFamily: 'Regular',
            ),
            backgroundColor: inputFillColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? appPrimaryColor : Colors.grey[400]!,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRemarkText(TextTheme textTheme, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildImageUploader({
    required Color inputFillColor,
    required Color borderColor,
    required int maxLimit,
    required List<XFile> imageList,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imageList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imageList[index].path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (imageList.isNotEmpty) const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(
              imageList.isEmpty
                  ? "Add Images (0/$maxLimit)"
                  : "Add More (${imageList.length}/$maxLimit)",
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: appPrimaryColor,
              side: const BorderSide(color: appPrimaryColor),
            ),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(TextTheme textTheme, String title) {
    return Text(
      title,
      style: textTheme.bodyMedium?.copyWith(fontFamily: 'Bold', fontSize: 16),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    required Color inputFillColor,
    required Color borderColor,
    required String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: true,
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

class MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  const MapPickerScreen({super.key, required this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _pickedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  void _onCameraMove(CameraPosition position) {
    _pickedLocation = position.target;
  }

  void _onConfirm() {
    Navigator.of(context).pop(_pickedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        centerTitle: true,
        backgroundColor: isDarkMode ? appDarkColor : Colors.grey[50],
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _onConfirm),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 16.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
          const Center(
            child: Icon(Icons.location_pin, color: appPrimaryColor, size: 50),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("Confirm This Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: appPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
