import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// الصفحات
import 'screens/splash_screen.dart';
import 'screens/register_page.dart';
import 'screens/otp_verification.dart';
import 'screens/role_selector_page.dart';
import 'screens/artisan_register.dart';
import 'screens/cv_register.dart';
import 'screens/home_page.dart';
import 'screens/search_artisan.dart';
import 'screens/artisan_map_page.dart';
import 'screens/search_worker.dart';
import 'screens/chat_page.dart';
import 'screens/notifications_page.dart';
import 'screens/settings_page.dart';
import 'screens/ads_page.dart';
import 'screens/map_view_page.dart';

// إعداد الإشعارات
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel',
    'الإشعارات',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'إشعار',
    message.notification?.body ?? '',
    platformDetails,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'يد بيد',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/role':
            return MaterialPageRoute(builder: (_) => const RoleSelectorPage());
          case '/artisan_register':
            return MaterialPageRoute(builder: (_) => const ArtisanRegisterPage());
          case '/cv_register':
            return MaterialPageRoute(builder: (_) => const CVRegisterPage());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/search_artisan':
            return MaterialPageRoute(builder: (_) => const SearchArtisanPage());
          case '/search_worker':
            return MaterialPageRoute(builder: (_) => const SearchWorkerPage());
          case '/notifications':
            return MaterialPageRoute(builder: (_) => const NotificationsPage());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsPage());
          case '/ads':
            return MaterialPageRoute(builder: (_) => const AdsPage());
          case '/OTP':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => OTPVerificationPage(phone: args['phone']),
            );
          case '/artisan_map':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ArtisanMapPage(profession: args['profession']),
            );
          case '/chat':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ChatPage(userName: args['userName']),
            );
          case '/map_view':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => MapViewPage(
                latitude: args['latitude'],
                longitude: args['longitude'],
                name: args['name'],
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
