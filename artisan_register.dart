import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import '../utils/page_transitions.dart';

class ArtisanRegisterPage extends StatefulWidget {
  const ArtisanRegisterPage({super.key});

  @override
  State<ArtisanRegisterPage> createState() => _ArtisanRegisterPageState();
}

class _ArtisanRegisterPageState extends State<ArtisanRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedProfession;
  String? selectedWilaya;
  String? selectedCommune;
  Position? currentPosition;
  List<File> selectedImages = [];
  Map<String, List<String>> wilayas = {};
  List<String> professions = [];

  @override
  void initState() {
    super.initState();
    loadProfessions();
    loadWilayas();
    getCurrentPosition();
  }

  Future<void> loadProfessions() async {
    final jsonString = await DefaultAssetBundle.of(context).loadString('assets/json/professions.json');
    final data = json.decode(jsonString);
    final List<String> loaded = [];
    for (var category in data['categories']) {
      loaded.addAll(List<String>.from(category['professions']));
    }
    setState(() => professions = loaded);
  }

  Future<void> loadWilayas() async {
    final jsonString = await DefaultAssetBundle.of(context).loadString('assets/json/wilayas.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    setState(() {
      wilayas = data.map((key, value) => MapEntry(key, List<String>.from(value)));
    });
  }

  Future<void> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    }
  }

  Future<void> pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => selectedImages = picked.take(3).map((img) => File(img.path)).toList());
    }
  }

  Future<List<String>> uploadImages() async {
    List<String> urls = [];
    for (File image in selectedImages) {
      final fileName = 'artisan_${DateTime.now().millisecondsSinceEpoch}_${image.hashCode}.jpg';
      final ref = FirebaseStorage.instance.ref().child('artisan_images/$fileName');
      await ref.putFile(image);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> saveArtisan() async {
    if (!_formKey.currentState!.validate()) return;

    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد موقعك الجغرافي')),
      );
      return;
    }

    final imageUrls = await uploadImages();
    final currentUser = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('artisans').add({
      'uid': currentUser?.uid ?? '',
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'profession': selectedProfession,
      'description': descriptionController.text.trim(),
      'wilaya': selectedWilaya,
      'commune': selectedCommune,
      'latitude': currentPosition!.latitude,
      'longitude': currentPosition!.longitude,
      'images': imageUrls,
      'rating': 0.0,
      'reviews': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل الحرفي بنجاح')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      FadePageRoute(page: const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل كـ حرفي')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) => value!.isEmpty ? 'الاسم مطلوب' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'رقم الهاتف مطلوب' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedProfession,
                decoration: const InputDecoration(labelText: 'الحرفة'),
                items: professions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) => setState(() => selectedProfession = val),
                validator: (value) => value == null ? 'يرجى اختيار الحرفة' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'وصف للخدمة'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'الوصف مطلوب' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedWilaya,
                decoration: const InputDecoration(labelText: 'الولاية (اختياري)'),
                items: wilayas.keys
                    .map((wilaya) => DropdownMenuItem(value: wilaya, child: Text(wilaya)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedWilaya = val;
                    selectedCommune = null;
                  });
                },
              ),
              if (selectedWilaya != null)
                DropdownButtonFormField<String>(
                  value: selectedCommune,
                  decoration: const InputDecoration(labelText: 'البلدية (اختياري)'),
                  items: wilayas[selectedWilaya]!
                      .map((commune) => DropdownMenuItem(value: commune, child: Text(commune)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedCommune = val),
                ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('اختيار صور للأعمال (حتى 3 صور)'),
              ),
              Wrap(
                spacing: 8,
                children: selectedImages
                    .map((img) => Image.file(img, width: 80, height: 80, fit: BoxFit.cover))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveArtisan,
                child: const Text('تسجيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
