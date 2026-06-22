import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavItem {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final String ownerName;
  final String ownerPhoto;

  const FavItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerPhoto,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'price': price,
        'imageUrl': imageUrl,
        'ownerName': ownerName,
        'ownerPhoto': ownerPhoto,
      };

  factory FavItem.fromMap(Map<String, dynamic> m) => FavItem(
        id: m['id']?.toString() ?? '',
        title: m['title']?.toString() ?? '',
        price: m['price']?.toString() ?? '',
        imageUrl: m['imageUrl']?.toString() ?? '',
        ownerName: m['ownerName']?.toString() ?? '',
        ownerPhoto: m['ownerPhoto']?.toString() ?? '',
      );
}

class FavouritesController extends GetxController {
  static const _prefsKey = 'zip_peer_favourites';

  final Map<String, FavItem> _items = {};

  List<FavItem> get items => _items.values.toList(growable: false);

  bool isFavourite(String id) => _items.containsKey(id);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void toggle(FavItem item) {
    if (_items.containsKey(item.id)) {
      _items.remove(item.id);
    } else {
      _items[item.id] = item;
    }
    update();
    _save();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      for (final m in list) {
        if (m is Map) {
          final item = FavItem.fromMap(Map<String, dynamic>.from(m));
          if (item.id.isNotEmpty) _items[item.id] = item;
        }
      }
      update();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(_items.values.map((i) => i.toMap()).toList()),
      );
    } catch (_) {}
  }
}
