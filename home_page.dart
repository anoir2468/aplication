import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_artisan.dart';
import 'search_worker.dart';
import 'ads_page.dart';
import 'chat_page.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'artisan_register.dart';
import 'cv_register.dart';
import '../utils/share_button_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = '';
  String phone = '';
  String gender = '';
  String location = '';
  List<String> roles = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'مستخدم';
      phone = prefs.getString('phone') ?? '';
      gender = prefs.getString('gender') ?? '';
      String? wilaya = prefs.getString('wilaya');
      String? commune = prefs.getString('commune');
      double? lat = prefs.getDouble('latitude');
      double? lng = prefs.getDouble('longitude');

      if (wilaya != null && commune != null) {
        location = '$wilaya - $commune';
      } else if (lat != null && lng != null) {
        location = 'موقعك: (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
      }

      roles = prefs.getStringList('roles') ?? [];
    });
  }

  void addRole(String role) async {
    if (!roles.contains(role) && roles.length < 3) {
      roles.add(role);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('roles', roles);
      setState(() {});
    }
  }

  Widget buildButton(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.teal),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('يد بيد'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 28),
            tooltip: 'الدردشة',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatPage(userName: name)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            tooltip: 'الإشعارات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(phone),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              decoration: const BoxDecoration(color: Colors.teal),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('الإعدادات'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.announcement),
              title: const Text('الإعلانات'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdsPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل الخروج'),
              onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'مرحبًا، $name',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildButton('البحث عن حرفي', Icons.search, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchArtisanPage()),
              );
            }),
            buildButton('البحث عن عامل (سيرة ذاتية)', Icons.work, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchWorkerPage()),
              );
            }),
            if (!roles.contains('artisan'))
              buildButton('تسجيل كـ حرفي', Icons.handyman, () {
                addRole('artisan');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ArtisanRegisterPage()),
                );
              }),
            if (!roles.contains('cv'))
              buildButton('تسجيل كـ طالب عمل', Icons.person_add, () {
                addRole('cv');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CVRegisterPage()),
                );
              }),
            if (roles.length >= 3)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'لقد وصلت إلى الحد الأقصى من الحسابات (3)',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: const ShareButton(),
    );
  }
}
