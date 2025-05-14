import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String name = '';
  String phone = '';
  String gender = '';
  String location = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'غير معروف';
      phone = prefs.getString('phone') ?? '';
      gender = prefs.getString('gender') ?? '';
      final wilaya = prefs.getString('wilaya');
      final commune = prefs.getString('commune');
      final lat = prefs.getDouble('latitude');
      final lng = prefs.getDouble('longitude');

      if (wilaya != null && commune != null) {
        location = '$wilaya - $commune';
      } else if (lat != null && lng != null) {
        location = 'موقعك: ($lat, $lng)';
      } else {
        location = 'غير محدد';
      }
    });
  }

  Future<void> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete(); // حذف من Firebase
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // حذف بيانات التخزين

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الحساب بنجاح')),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف الحساب: $e')),
      );
    }
  }

  Future<void> confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
            'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteAccount();
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('الاسم الكامل'),
            subtitle: Text(name),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('رقم الهاتف'),
            subtitle: Text(phone),
          ),
          ListTile(
            leading: const Icon(Icons.transgender),
            title: const Text('الجنس'),
            subtitle: Text(gender),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('الموقع'),
            subtitle: Text(location),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('تعديل المعلومات'),
            onTap: () {
              Navigator.pushNamed(context, '/register');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('تسجيل الخروج',
                style: TextStyle(color: Colors.orange)),
            onTap: logout,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title:
                const Text('حذف الحساب', style: TextStyle(color: Colors.red)),
            onTap: confirmDelete,
          ),
        ],
      ),
    );
  }
}
