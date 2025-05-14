import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Share.share(
          '📱 تطبيق يد بيد 🇩🇿 هو منصة جزائرية تربطك بالحرفيين وطالبي العمل بالقرب منك.\n\n✨ حمل تطبيق يد بيد الآن!',
          subject: 'خدمتك أقرب مما تتخيل!',
        );
      },
      icon: const Icon(Icons.share),
      label: const Text('مشاركة'),
      backgroundColor: Colors.teal,
    );
  }
}
