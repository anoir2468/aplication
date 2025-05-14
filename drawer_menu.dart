import 'package:flutter/material.dart';
import 'package:yad_byad_finaly/screens/AboutPrivacyPage.dart';
import './AboutPrivacyPage.dart';

class DrawerMenu extends StatelessWidget {
  final Function(String) onSelect;
  const DrawerMenu({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.white),
                SizedBox(height: 10),
                Text('مرحباً بك',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('حسابي'),
            onTap: () => onSelect('profile'),
          ),
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('الإعلانات'),
            onTap: () => onSelect('ads'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('المفضلة'),
            onTap: () => onSelect('favorites'),
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('من نحن / سياسة الخصوصية'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPrivacyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('اتصل بنا'),
            onTap: () => onSelect('contact'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: () => onSelect('logout'),
          ),
        ],
      ),
    );
  }
}
