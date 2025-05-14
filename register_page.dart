import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'otp_verification.dart';
import '../utils/page_transitions.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String? selectedGender;
  String? selectedWilaya;
  String? selectedCommune;
  Position? currentPosition;
  Map<String, List<String>> wilayas = {};
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    loadWilayas();
    getCurrentPosition();
  }

  Future<void> loadWilayas() async {
    final jsonString =
        await rootBundle.loadString('assets/json/algeria_regions.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    setState(() {
      wilayas =
          data.map((key, value) => MapEntry(key, List<String>.from(value)));
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

  void goToVerification() async {
    if (_formKey.currentState!.validate()) {
      bool hasLocation = currentPosition != null;
      bool hasWilaya = selectedWilaya != null && selectedCommune != null;

      if (!hasLocation && !hasWilaya) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تحديد موقعك أو ولايتك وبلديتك')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameController.text);
      await prefs.setString('phone', phoneController.text);
      await prefs.setString('gender', selectedGender!);
      if (hasWilaya) {
        await prefs.setString('wilaya', selectedWilaya!);
        await prefs.setString('commune', selectedCommune!);
      }
      if (hasLocation) {
        await prefs.setDouble('latitude', currentPosition!.latitude);
        await prefs.setDouble('longitude', currentPosition!.longitude);
      }
      if (selectedImage != null) {
        await prefs.setString('imagePath', selectedImage!.path);
      }

      Navigator.push(
        context,
        FadePageRoute(
          page: OTPVerificationPage(phone: phoneController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل حساب جديد')),
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
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : null,
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
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'رقم الهاتف مطلوب' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: 'الجنس'),
                  items: ['ذكر', 'أنثى']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedGender = val),
                  validator: (value) =>
                      value == null ? 'يرجى اختيار الجنس' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedWilaya,
                  decoration: const InputDecoration(labelText: 'الولاية'),
                  items: wilayas.keys
                      .map((wilaya) =>
                          DropdownMenuItem(value: wilaya, child: Text(wilaya)))
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
                        .map((commune) => DropdownMenuItem(
                            value: commune, child: Text(commune)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCommune = val),
                  ),
                const SizedBox(height: 10),
                if (currentPosition != null)
                  Text(
                    'موقعك: ${currentPosition!.latitude}, ${currentPosition!.longitude}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ElevatedButton(
                  onPressed: goToVerification,
                  child: const Text('تأكيد ومتابعة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
