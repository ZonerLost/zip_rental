import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/models/eco/eco_models.dart';

// Response bodies captured live from the production API
// (au2p3vkiqi.us-east-1.awsapprunner.com/api/v1) for the three public,
// read-only Eco Impact endpoints — verifying the parsing models below
// against real payloads rather than just the doc examples.
const _userLeaderboardBody = '''
{"success":true,"message":"User leaderboard retrieved","data":[
  {"_id":"69d67a98065b99a5a3467042","totalRentals":1,"user":{"firstName":"Jane","lastName":"Smith","location":{}},"totalCO2":40},
  {"_id":"6a46342e07b67b38132c831c","totalRentals":1,"user":{"firstName":"Renter","lastName":"Tester","location":{}},"totalCO2":27}
]}
''';

const _cityLeaderboardBody = '''
{"success":true,"message":"City leaderboard retrieved","data":[
  {"province":"QC","totalRentals":2,"city":"Montreal","totalCO2":67}
]}
''';

const _categoriesBody = '''
{"success":true,"message":"CO₂ categories retrieved","data":[
  {"category":"tools","co2SavedKg":27,"kmEquivalent":128.5,"description":"Renting saves 27 kg CO₂ (= 128.5 km by car)"},
  {"category":"cycling","co2SavedKg":40,"kmEquivalent":190.4,"description":"Renting saves 40 kg CO₂ (= 190.4 km by car)"},
  {"category":"vehicles","co2SavedKg":120,"kmEquivalent":571.2,"description":"Renting saves 120 kg CO₂ (= 571.2 km by car)"}
]}
''';

// Doc-example payloads for the two auth-required endpoints (couldn't be
// live-tested without a real account — see model fromJson still handles
// them field-for-field per the spec).
const _myImpactBody = '''
{"lifetime":{"totalCO2":40,"totalKm":190.4,"totalRentals":1,"equivalence":"190.4 km by car"},
 "badge":{"id":"eco_starter","label":"Eco Starter","minCO2":0},
 "nextBadge":{"id":"green_achiever","label":"Green Achiever","minCO2":50,"co2Remaining":10}}
''';

const _bookingImpactBody = '''
{"co2SavedKg":40,"kmEquivalent":190.4,"category":"cycling",
 "message":"By renting this item, you saved 40 kg of CO2, equivalent to 190.4 km by car"}
''';

Map<String, dynamic> _decode(String body) =>
    jsonDecode(body) as Map<String, dynamic>;

List<Map<String, dynamic>> _decodeDataList(String body) {
  final root = _decode(body);
  return (root['data'] as List)
      .map((e) => e as Map<String, dynamic>)
      .toList();
}

void main() {
  group('EcoLeaderboardUserModel (live payload)', () {
    final entries = _decodeDataList(
      _userLeaderboardBody,
    ).map(EcoLeaderboardUserModel.fromJson).toList();

    test('parses both entries', () {
      expect(entries, hasLength(2));
    });

    test('first entry matches the top scorer', () {
      final jane = entries[0];
      expect(jane.id, '69d67a98065b99a5a3467042');
      expect(jane.fullName, 'Jane Smith');
      expect(jane.totalCO2, 40);
      expect(jane.totalRentals, 1);
    });

    test('empty location map does not crash city parsing', () {
      expect(entries[0].city, isNull);
    });
  });

  group('EcoLeaderboardCityModel (live payload)', () {
    test('parses city + province + totals', () {
      final entry = EcoLeaderboardCityModel.fromJson(
        _decodeDataList(_cityLeaderboardBody).single,
      );
      expect(entry.city, 'Montreal');
      expect(entry.province, 'QC');
      expect(entry.totalCO2, 67);
      expect(entry.totalRentals, 2);
      expect(entry.displayName, 'Montreal, QC');
    });
  });

  group('EcoCategoryModel (live payload)', () {
    final categories = _decodeDataList(
      _categoriesBody,
    ).map(EcoCategoryModel.fromJson).toList();

    test('parses category CO2 fields', () {
      final cycling = categories.firstWhere((c) => c.category == 'cycling');
      expect(cycling.co2SavedKg, 40);
      expect(cycling.kmEquivalent, 190.4);
      expect(cycling.description, contains('40 kg'));
    });

    test('vehicles has the highest footprint in this sample', () {
      final vehicles = categories.firstWhere((c) => c.category == 'vehicles');
      expect(vehicles.co2SavedKg, 120);
    });
  });

  group('MyEcoImpactModel (doc example)', () {
    final model = MyEcoImpactModel.fromJson(_decode(_myImpactBody));

    test('parses lifetime stats', () {
      expect(model.lifetime.totalCO2, 40);
      expect(model.lifetime.totalKm, 190.4);
      expect(model.lifetime.totalRentals, 1);
      expect(model.lifetime.equivalence, '190.4 km by car');
    });

    test('parses current + next badge', () {
      expect(model.badge?.id, 'eco_starter');
      expect(model.badge?.label, 'Eco Starter');
      expect(model.nextBadge?.id, 'green_achiever');
      expect(model.nextBadge?.minCO2, 50);
      expect(model.nextBadge?.co2Remaining, 10);
    });
  });

  group('BookingEcoImpactModel (doc example)', () {
    test('parses co2/km/category/message', () {
      final model = BookingEcoImpactModel.fromJson(_decode(_bookingImpactBody));
      expect(model.co2SavedKg, 40);
      expect(model.kmEquivalent, 190.4);
      expect(model.category, 'cycling');
      expect(model.message, contains('40 kg of CO2'));
    });
  });
}
