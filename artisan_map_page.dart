import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class ArtisanMapPage extends StatefulWidget {
  final String profession;
  const ArtisanMapPage({super.key, required this.profession});

  @override
  State<ArtisanMapPage> createState() => _ArtisanMapPageState();
}

class _ArtisanMapPageState extends State<ArtisanMapPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final LatLng _defaultPosition = const LatLng(36.752778, 3.042222);
  Position? _currentPosition;
  List<Map<String, dynamic>> _nearbyArtisans = [];

  @override
  void initState() {
    super.initState();
    _determinePosition().then((_) => _loadArtisans());
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _currentPosition = await Geolocator.getCurrentPosition();
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _loadArtisans() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('artisans')
        .where('profession', isEqualTo: widget.profession)
        .get();

    final List<Map<String, dynamic>> nearby = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lat = data['latitude'];
      final lng = data['longitude'];
      if (lat != null && lng != null) {
        final LatLng position = LatLng(lat, lng);
        _markers.add(Marker(
          markerId: MarkerId(doc.id),
          position: position,
          infoWindow: InfoWindow(
            title: data['name'],
            snippet: data['phone'],
            onTap: () => _showDetailsDialog(doc.id, data),
          ),
        ));

        double? distance;
        if (_currentPosition != null) {
          distance = _calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            lat,
            lng,
          );
        }

        data['id'] = doc.id;
        data['distance'] = distance;
        nearby.add(data);
      }
    }

    nearby
        .sort((a, b) => (a['distance'] ?? 999).compareTo(b['distance'] ?? 999));

    setState(() {
      _nearbyArtisans = nearby;
    });
  }

  void _showDetailsDialog(String artisanId, Map<String, dynamic> artisan) {
    final rating = (artisan['rating'] ?? 0).toDouble();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(artisan['name'] ?? ''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (artisan['image'] != null)
              Image.network(artisan['image'], height: 100),
            const SizedBox(height: 10),
            Text('المهنة: ${artisan['profession']}'),
            Text('رقم الهاتف: ${artisan['phone']}'),
            Text('التقييم: ⭐ ${rating.toStringAsFixed(1)}'),
            const SizedBox(height: 10),
            Text(artisan['description'] ?? '',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.star),
            label: const Text('قيّمه'),
            onPressed: () {
              Navigator.pop(context);
              _showRatingDialog(artisanId);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.call),
            label: const Text('اتصال'),
            onPressed: () => _callPhone(artisan['phone']),
          )
        ],
      ),
    );
  }

  void _showRatingDialog(String artisanId) {
    double selectedRating = 0;
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قيّم هذا الحرفي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1.0;
                    });
                    Navigator.pop(context);
                    _showRatingDialog(artisanId);
                  },
                );
              }),
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'تعليقك (اختياري)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedRating > 0) {
                final docRef = FirebaseFirestore.instance
                    .collection('artisans')
                    .doc(artisanId);
                final docSnap = await docRef.get();
                final data = docSnap.data();
                double currentRating = (data?['rating'] ?? 0).toDouble();
                int ratingCount = (data?['ratingCount'] ?? 0).toInt();
                double newRating =
                    ((currentRating * ratingCount) + selectedRating) /
                        (ratingCount + 1);
                await docRef.update({
                  'rating': newRating,
                  'ratingCount': ratingCount + 1,
                  'reviews': FieldValue.arrayUnion([
                    {
                      'stars': selectedRating,
                      'comment': commentController.text,
                      'timestamp': Timestamp.now(),
                    }
                  ]),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _callPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إجراء الاتصال')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultPosition;

    return Scaffold(
      appBar: AppBar(title: Text('خريطة ${widget.profession}')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: center, zoom: 11),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _nearbyArtisans.length,
              itemBuilder: (context, index) {
                final artisan = _nearbyArtisans[index];
                final dist = artisan['distance'] != null
                    ? artisan['distance'].toStringAsFixed(1) + ' كم'
                    : 'غير معروف';
                final rating = artisan['rating'] != null
                    ? '⭐ ${artisan['rating'].toStringAsFixed(1)}'
                    : 'بدون تقييم';
                return Card(
                  child: ListTile(
                    title: Text('${artisan['name'] ?? 'بدون اسم'} - $rating'),
                    subtitle: Text('📞 ${artisan['phone']}  •  📍 $dist'),
                    onTap: () => _showDetailsDialog(artisan['id'], artisan),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
