import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gunsay/main.dart';

import 'test_setup.dart';

void main() {
  setUpAll(() async {
    await initTestEnvironment();
  });

  group('Etkinlik serialization', () {
    test('toJson/fromJson roundtrip preserves fields', () {
      final now = DateTime(2026, 9, 18, 12, 34, 56);
      final etkinlik = Etkinlik('Doğum Günü', now, muzikYolu: '/path/to/music.mp3', id: 'abc123');

      final jsonMap = etkinlik.toJson();
      final encoded = jsonEncode(jsonMap);
      final decoded = jsonDecode(encoded);

      final restored = Etkinlik.fromJson(Map<String, dynamic>.from(decoded));

      expect(restored.id, etkinlik.id);
      expect(restored.baslik, etkinlik.baslik);
      expect(restored.tarih, etkinlik.tarih);
      expect(restored.muzikYolu, etkinlik.muzikYolu);
    });
  });

  group('AppLocale', () {
    test('getName returns known language and falls back to uppercase code', () {
      expect(AppLocale.getName('tr'), 'Türkçe');
      expect(AppLocale.getName('en'), 'English');
      expect(AppLocale.getName('xx'), 'XX');
    });
  });

  group('AppSettings', () {
    test('copyWith replaces fields', () {
      final original = AppSettings(themeMode: ThemeMode.system, locale: const Locale('tr'));
      final updated = original.copyWith(themeMode: ThemeMode.dark, locale: const Locale('en'));

      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.locale.languageCode, 'en');
      // original unchanged
      expect(original.themeMode, ThemeMode.system);
      expect(original.locale.languageCode, 'tr');
    });

    testWidgets('save writes values to SharedPreferences', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final settings = AppSettings(themeMode: ThemeMode.dark, locale: const Locale('en'));
      await settings.save();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('app_theme_index'), ThemeMode.dark.index);
      expect(prefs.getString('app_locale_code'), 'en');
    });
  });
}
