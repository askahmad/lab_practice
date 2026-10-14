import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;
  final String userEmail;
  final String userStatus;

  const HomePage({
    super.key,
    this.isAdmin = false,
    this.userEmail = '',
    this.userStatus = 'user',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();
  bool _isLoadingLocation = false;

  // Stored location state
  double? _currentLat;
  double? _currentLng;
  DateTime? _lastUpdated;

  // Initial default map center (Islamabad, Pakistan)
  static const LatLng _initialCenter = LatLng(33.6844, 73.0479);

  @override
  void initState() {
    super.initState();
    _loadSavedLocationFromFirestore();
  }

  // Load previously saved location from Firestore on page open (if any)
  Future<void> _loadSavedLocationFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_locations')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        final Timestamp? timestamp = data['updatedAt'] as Timestamp?;

        if (lat != null && lng != null && mounted) {
          setState(() {
            _currentLat = lat;
            _currentLng = lng;
            if (timestamp != null) {
              _lastUpdated = timestamp.toDate();
            }
          });
          // Move map camera to saved coordinates
          _mapController.move(LatLng(lat, lng), 15.0);
        }
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  // Fetch current location, move map camera, add marker, and update Firestore
  Future<void> _fetchAndSaveLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 1. Check if GPS / Location services are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please turn on GPS on your device.';
      }

      // 2. Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied. Please allow permission to fetch location.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them from App Settings.';
      }

      // 3. Obtain current user position (latitude & longitude)
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final LatLng userLatLng = LatLng(position.latitude, position.longitude);

      // 4. Move Map camera to current location
      _mapController.move(userLatLng, 16.5);

      // 5. Display marker on user's current location & update UI
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
        _lastUpdated = DateTime.now();
      });

      // 6 & 7. Store / Update user's location in Firebase Firestore
      await _syncLocationToFirestore(position.latitude, position.longitude);

      Get.snackbar(
        'Location Updated',
        'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}\nSaved to Firebase Firestore!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    } catch (e) {
      debugPrint('Location Error: $e');
      Get.snackbar(
        'Location Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // Write or update the location record in Firebase Firestore
  Future<void> _syncLocationToFirestore(double latitude, double longitude) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw 'User not authenticated.';
    }

    final locationData = {
      'userId': user.uid,
      'email': user.email ?? widget.userEmail,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Save under 'user_locations' collection with user.uid as Document ID
    await FirebaseFirestore.instance
        .collection('user_locations')
        .doc(user.uid)
        .set(locationData, SetOptions(merge: true));
  }

  // Logout dialog
  Future<void> _confirmLogout() async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to sign out from your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => const LoginPage());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayEmail = currentUser?.email ?? widget.userEmail;
    final displayName = currentUser?.displayName ??
        (displayEmail.isNotEmpty ? displayEmail.split('@').first : 'User');

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Map & Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'User: $displayName',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive Map Widget (OpenStreetMap - 100% Free, No Credit Card / API Key required)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLat != null && _currentLng != null
                  ? LatLng(_currentLat!, _currentLng!)
                  : _initialCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.practice_app',
              ),
              if (_currentLat != null && _currentLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentLat!, _currentLng!),
                      width: 60,
                      height: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            size: 38,
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top Info Card showing live/saved coordinates & Firestore status
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.deepPurple,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentLat != null
                              ? 'Lat: ${_currentLat!.toStringAsFixed(5)}, Lng: ${_currentLng!.toStringAsFixed(5)}'
                              : 'Tap FAB to fetch current location',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _lastUpdated != null
                              ? 'Synced to Firestore: ${_lastUpdated!.hour}:${_lastUpdated!.minute.toString().padLeft(2, '0')}:${_lastUpdated!.second.toString().padLeft(2, '0')}'
                              : 'Location not fetched yet',
                          style: TextStyle(
                            fontSize: 11,
                            color: _lastUpdated != null ? Colors.green.shade700 : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button (FAB) at bottom-right corner of screen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoadingLocation ? null : _fetchAndSaveLocation,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: _isLoadingLocation
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.my_location_rounded),
        label: Text(
          _isLoadingLocation ? 'Locating...' : 'Get & Save Location',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}