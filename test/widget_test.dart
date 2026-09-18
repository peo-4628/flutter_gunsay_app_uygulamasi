// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gunsay/main.dart';

void main() {
  testWidgets('Uygulama açılır ve ana ekran görünür', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const GunSayerApp(disablePlatformPlugins: true));

    expect(find.text('Gün Sayacı'), findsOneWidget);
    expect(find.text('Seçilen Tarihe Göre:'), findsOneWidget);
  });
}
