import 'package:flutter/material.dart';
import '../utils/page_transitions.dart';
import 'artisan_map_page.dart';

class SearchArtisanPage extends StatefulWidget {
  const SearchArtisanPage({super.key});

  @override
  State<SearchArtisanPage> createState() => _SearchArtisanPageState();
}

class _SearchArtisanPageState extends State<SearchArtisanPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allProfessions = [];
  List<Map<String, String>> _filteredProfessions = [];

  @override
  void initState() {
    super.initState();
    _loadProfessions();
    _searchController.addListener(_filter);
  }

  void _loadProfessions() {
    _allProfessions = [
      // خدمات السيارات والنقل
      {"name": "ميكانيكي سيارات", "image": "mechanic.png"},
      {"name": "كهربائي سيارات", "image": "car_electrician.png"},
      {"name": "مصلح زجاج السيارات", "image": "glass_repair.png"},
      {"name": "مصلح مبرد السيارات (رادياتور)", "image": "radiator.png"},
      {"name": "مصلح عجلات وتوازن", "image": "wheel_balance.png"},
      {"name": "عامل صفائح سيارات", "image": "sheet_worker.png"},
      {"name": "مصلح تكييف السيارات", "image": "car_ac.png"},
      {"name": "مصلح هواتف السيارة", "image": "car_phone.png"},
      {"name": "غسيل وتشحيم السيارات", "image": "car_wash.png"},
      {"name": "وكالة كراء السيارات", "image": "car_rental.png"},

      // خدمات السكن والبناء
      {"name": "بناء", "image": "builder.png"},
      {"name": "سبّاك (بلومبيي)", "image": "plumber.png"},
      {"name": "كهربائي منازل", "image": "electrician.png"},
      {"name": "دهّان", "image": "painter.png"},
      {"name": "مركّب سيراميك", "image": "tile.png"},
      {"name": "نجار الخشب", "image": "carpenter.png"},
      {"name": "نجار مطابخ عصرية", "image": "kitchen.png"},
      {"name": "نجار ألومنيوم وبلاستيك", "image": "aluminium.png"},
      {"name": "حدّاد", "image": "blacksmith.png"},
      {"name": "عامل الزجاج", "image": "glass.png"},
      {"name": "تلحيم الحديد (سودور)", "image": "welder.png"},
      {"name": "تركيب الأسقف", "image": "roof.png"},

      // التبريد والتكييف
      {"name": "مصلح مكيفات الهواء", "image": "ac_repair.png"},
      {"name": "مصلح آلات الغسيل", "image": "washing_machine.png"},
      {"name": "مصلح ثلاجات ومجمدات", "image": "fridge_repair.png"},
      {"name": "تركيب سخان الماء (شوفو)", "image": "water_heater.png"},

      // التكنولوجيا والمعلوماتية
      {"name": "خدمات الإعلام الآلي", "image": "it_service.png"},
      {"name": "مصلح كمبيوترات وطابعات", "image": "computer_repair.png"},
      {"name": "مصلح هواتف نقالة", "image": "phone_repair.png"},
      {"name": "تركيب كاميرات المراقبة", "image": "cctv.png"},
      {"name": "مصمم غرافيك", "image": "graphic.png"},
      {"name": "مطور مواقع وتطبيقات", "image": "developer.png"},

      // الطباعة والإشهار
      {"name": "مطبعة", "image": "printer.png"},
      {"name": "وكالة طباعة وإشهار", "image": "ad_agency.png"},
      {"name": "خدمات تصميم ولافتات", "image": "signage.png"},
      {"name": "خدمات ستيكارات", "image": "sticker.png"},

      // السياحة والخدمات
      {"name": "وكالة سياحة وأسفار", "image": "travel.png"},
      {"name": "ترجمة وتوثيق", "image": "translate.png"},
      {"name": "صيانة مكاتب", "image": "office_maintenance.png"},
      {"name": "فوطوغرافي مناسبات", "image": "photographer.png"},
      {"name": "خدمات الأعراس", "image": "wedding.png"},

      // الحرف المتنوعة
      {"name": "خيّاط", "image": "tailor.png"},
      {"name": "صانع الأحذية", "image": "shoemaker.png"},
      {"name": "مصفف شعر", "image": "hairdresser.png"},
      {"name": "حلاق", "image": "barber.png"},
      {"name": "خباز تقليدي", "image": "baker.png"},
      {"name": "طباخ منزلي", "image": "chef.png"},
      {"name": "نادل مناسبات", "image": "waiter.png"},
      {"name": "فلاح", "image": "farmer.png"},
      {"name": "تربية نحل", "image": "bee.png"},
      {"name": "صانع تقليدي", "image": "artisan.png"},
    ];
    _filteredProfessions = _allProfessions;
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProfessions = _allProfessions.where((item) {
        return item['name']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الحرف')), 
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث عن حرفة...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProfessions.length,
              itemBuilder: (context, index) {
                final item = _filteredProfessions[index];
                return ListTile(
                  leading: Image.asset(
                    'assets/images/artisans/${item['image']}',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                  ),
                  title: Text(item['name']!),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      FadePageRoute(
                        page: ArtisanMapPage(profession: item['name']!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
