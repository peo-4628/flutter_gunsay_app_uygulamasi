import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:gunsay/main.dart';

import 'test_setup.dart';

void main() {
  setUpAll(() async {
    await initTestEnvironment();
  });

  testWidgets('Open settings and events sheet', (WidgetTester tester) async {
    await tester.pumpWidget(const GunSayerApp(disablePlatformPlugins: true));
    await tester.pumpAndSettle();

    expect(find.text('Gün Sayacı'), findsOneWidget);

    // Open settings
    final settingsButton = find.byTooltip('Ayarlar');
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();
    expect(find.text('Ayarlar'), findsOneWidget);

    // Go back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Open list sheet
    final listButton = find.widgetWithIcon(FloatingActionButton, Icons.list);
    expect(listButton, findsOneWidget);
    await tester.tap(listButton);
    await tester.pumpAndSettle();
    expect(find.text('Etkinlikler'), findsOneWidget);
  });
}
