import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'map_view_page.dart';
import 'chat_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SearchWorkerPage extends StatefulWidget {
  const SearchWorkerPage({super.key});

  @override
  State<SearchWorkerPage> createState() => _SearchWorkerPageState();
}

class _SearchWorkerPageState extends State<SearchWorkerPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> workers = [];
  List<Map<String, dynamic>> filteredWorkers = [];
  Position? _currentPosition;
  String? userWilaya;
  String? userCommune;

  @override
  void initState() {
    super.initState();
    _loadUserLocation().then((_) => _getCurrentLocation().then((__) => fetchWorkers()));
  }

  Future<void> _loadUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    userWilaya = prefs.getString('wilaya');
    userCommune = prefs.getString('commune');
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      _currentPosition = await Geolocator.getCurrentPosition();
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p)/2 +
              cos(lat1 * p) * cos(lat2 * p) *
              (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> fetchWorkers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cv_profiles')
        .orderBy('timestamp', descending: true)
        .get();

    workers = snapshot.docs.map((doc) {
      final data = doc.data();
      double? distance;
      if (_currentPosition != null && data['latitude'] != null && data['longitude'] != null) {
        distance = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          data['latitude'],
          data['longitude'],
        );
      }
      return {
        'name': data['name'] ?? '',
        'phone': data['phone'] ?? '',
        'gender': data['gender'] ?? '',
        'profession': data['profession'] ?? '',
        'experience': data['experience'] ?? '',
        'age': data['age']?.toString() ?? '',
        'languages': data['languages'] ?? '',
        'wilaya': data['wilaya'] ?? '',
        'commune': data['commune'] ?? '',
        'image': data['image'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'distance': distance
      };
    }).toList();

    // فلترة أولية حسب الولاية والبلدية أو المسافة
    filteredWorkers = workers.where((worker) {
      if (userWilaya != null && userCommune != null) {
        return worker['wilaya'] == userWilaya && worker['commune'] == userCommune;
      } else if (_currentPosition != null) {
        return worker['distance'] != null && worker['distance'] < 50; // 50 كم كحد تقريبي
      }
      return true;
    }).toList();

    setState(() {});
  }

  void _filter(String query) {
    if (query.trim().isEmpty) {
      fetchWorkers();
      return;
    }
    setState(() {
      filteredWorkers = workers.where((worker) {
        return worker['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
            worker['profession'].toString().toLowerCase().contains(query.toLowerCase()) ||
            worker['wilaya'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _callPhone(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إجراء الاتصال')),
      );
    }
  }

  void _openMapView(double lat, double lng, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapViewPage(
          latitude: lat,
          longitude: lng,
          name: name,
        ),
      ),
    );
  }

  void _openChat(String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(userName: userName),
      ),
    );
  }

  void _openDetails(Map<String, dynamic> worker) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(worker['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (worker['image'] != null)
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(worker['image']),
                  ),
                ),
              const SizedBox(height: 10),
              Text('المهنة: ${worker['profession']}'),
              Text('السن: ${worker['age']}'),
              Text('الخبرة: ${worker['experience']}'),
              Text('اللغات: ${worker['languages']}'),
              Text('الولاية: ${worker['wilaya']}'),
              Text('البلدية: ${worker['commune']}'),
              if (worker['distance'] != null)
                Text('المسافة: ${worker['distance'].toStringAsFixed(1)} كم'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('اتصل به'),
                onPressed: () => _callPhone(worker['phone']),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('محادثة'),
                onPressed: () => _openChat(worker['name']),
              ),
              if (worker['latitude'] != null && worker['longitude'] != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text('عرض على الخريطة'),
                  onPressed: () => _openMapView(
                    worker['latitude'],
                    worker['longitude'],
                    worker['name'],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('رجوع'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البحث عن عامل')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث باسم أو مهنة أو ولاية...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: filteredWorkers.isEmpty
                ? const Center(child: Text('لا توجد نتائج'))
                : ListView.builder(
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      final worker = filteredWorkers[index];
                      final distanceLabel = worker['distance'] != null
                          ? '${worker['distance'].toStringAsFixed(1)} كم'
                          : 'بدون تحديد';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: worker['image'] != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(worker['image']),
                                )
                              : const Icon(Icons.person),
                          title: Text(worker['name']),
                          subtitle: Text('${worker['profession']} - $distanceLabel'),
                          trailing: Text(worker['wilaya']),
                          onTap: () => _openDetails(worker),
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
