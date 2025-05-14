import 'package:flutter/material.dart';

class AboutPrivacyPage extends StatelessWidget {
  const AboutPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('من نحن و سياسة الخصوصية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'من نحن',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          const Text(
            '"يد بيد" هو تطبيق جزائري يهدف إلى ربط المواطنين بالحرفيين وطالبي العمل بكل سهولة وسرعة. نطمح لتوفير منصة موثوقة ومبسطة للجميع من أجل تحسين فرص الشغل وتوفير الخدمات المهنية في كل أنحاء الوطن.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 30),
          const Text(
            'سياسة الخصوصية',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          const Text(
            'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك. يتم استخدام معلوماتك (مثل الموقع، الاسم، رقم الهاتف) فقط لتسهيل التواصل والخدمة داخل التطبيق، ولا يتم مشاركتها مع أي جهة خارجية. كما يتم تأمين البيانات من خلال Firebase بما يضمن حمايتها.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 20),
          const Text(
            'باستخدامك لهذا التطبيق، فإنك توافق على هذه السياسة. نحن نعمل باستمرار على تحسين أمان وسرية معلومات المستخدمين.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
