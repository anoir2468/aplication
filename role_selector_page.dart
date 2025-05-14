import 'package:flutter/material.dart';
import 'artisan_register.dart';
import 'cv_register.dart';
import 'home_page.dart';

class RoleSelectorPage extends StatelessWidget {
  const RoleSelectorPage({super.key});

  void goTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: const Text('اختيار نوع الحساب')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'من فضلك اختر طريقة استخدامك للتطبيق:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),

              // حرفي
              GestureDetector(
                onTap: () => goTo(context, const ArtisanRegisterPage()),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.handyman, size: 36),
                    title: const Text('تسجيل كحرفي'),
                    subtitle: const Text('أنشئ حسابك كحرفي لعرض خدماتك'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // سيرة ذاتية
              GestureDetector(
                onTap: () => goTo(context, const CVRegisterPage()),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.badge, size: 36),
                    title: const Text('تسجيل كسيرة ذاتية'),
                    subtitle: const Text('أنشئ سيرتك الذاتية للبحث عن عمل'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // تصفح فقط
              GestureDetector(
                onTap: () => goTo(context, const HomePage()),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.visibility, size: 36),
                    title: const Text('تصفح فقط'),
                    subtitle: const Text('استخدم التطبيق كمستعرض عادي'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
