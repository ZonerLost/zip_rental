import 'package:get/get.dart';

class LanguageController extends GetxController {
  String selected = 'en';

  final List<Map<String, dynamic>> languages = const [
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English'},
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'French'},
  ];

  void select(String code) {
    selected = code;
    update();
  }
}
