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

class CVRegisterPage extends StatefulWidget {
  const CVRegisterPage({super.key});

  @override
  State<CVRegisterPage> createState() => _CVRegisterPageState();
}

class _CVRegisterPageState extends State<CVRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final professionController = TextEditingController();
  final experienceController = TextEditingController();
  final languagesController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();

  String? selectedGender;
  String? selectedWilaya;
  String? selectedCommune;
  Position? currentPosition;
  File? selectedImage;
  String phone = '';
  Map<String, List<String>> wilayas = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadWilayas();
    getCurrentPosition();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      phone = prefs.getString('phone') ?? '';
    });
  }

  Future<void> loadWilayas() async {
    final jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/json/algeria_regions.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    setState(() {
      wilayas = data.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
    });
  }

  Future<void> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future<String?> uploadImageToFirebase() async {
    if (selectedImage == null) return null;
    final fileName = 'cv_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child('cv_images/$fileName');
    await ref.putFile(selectedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> saveCV() async {
    if (!_formKey.currentState!.validate()) return;

    final hasLocation = currentPosition != null;
    final hasWilaya = selectedWilaya != null && selectedCommune != null;

    if (!hasLocation && !hasWilaya) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد موقعك أو ولايتك وبلديتك')),
      );
      return;
    }

    final imageUrl = await uploadImageToFirebase();
    final currentUser = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('cv_profiles').add({
      'uid': currentUser?.uid ?? '',
      'name': nameController.text.trim(),
      'phone': phone,
      'gender': selectedGender,
      'profession': professionController.text.trim(),
      'experience': experienceController.text.trim(),
      'languages': languagesController.text.trim(),
      'age': ageController.text.trim(),
      'wilaya': selectedWilaya,
      'commune': selectedCommune,
      'latitude': currentPosition?.latitude,
      'longitude': currentPosition?.longitude,
      'image': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل السيرة الذاتية بنجاح')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل سيرة ذاتية'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      selectedImage != null ? FileImage(selectedImage!) : null,
                  child: selectedImage == null
                      ? const Icon(Icons.add_a_photo, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) => value!.isEmpty ? 'الاسم مطلوب' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(labelText: 'الجنس'),
                items: ['ذكر', 'أنثى']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => selectedGender = val),
                validator: (value) => value == null ? 'اختر الجنس' : null,
              ),
              TextFormField(
                controller: professionController,
                decoration: const InputDecoration(labelText: 'المهنة'),
                validator: (value) => value!.isEmpty ? 'المهنة مطلوبة' : null,
              ),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'السن'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: experienceController,
                decoration: const InputDecoration(labelText: 'الخبرة'),
              ),
              TextFormField(
                controller: languagesController,
                decoration: const InputDecoration(labelText: 'اللغات'),
              ),
              DropdownButtonFormField<String>(
                value: selectedWilaya,
                decoration: const InputDecoration(labelText: 'الولاية'),
                items: wilayas.keys
                    .map(
                      (wilaya) => DropdownMenuItem(
                        value: wilaya,
                        child: Text(wilaya),
                      ),
                    )
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
                  decoration: const InputDecoration(labelText: 'البلدية'),
                  items: wilayas[selectedWilaya]!
                      .map(
                        (commune) => DropdownMenuItem(
                          value: commune,
                          child: Text(commune),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedCommune = val),
                ),
              if (currentPosition != null)
                Text(
                  'موقعك: ${currentPosition!.latitude}, ${currentPosition!.longitude}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: saveCV, child: const Text('تسجيل')),
            ],
          ),
        ),
      ),
    );
  }
}
