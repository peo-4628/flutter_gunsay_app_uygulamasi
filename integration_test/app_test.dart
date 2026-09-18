import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:gunsay/main.dart';

import '../test/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  testWidgets('app smoke test - launch and open add page', (WidgetTester tester) async {
    await tester.pumpWidget(const GunSayerApp(disablePlatformPlugins: true));
    await tester.pumpAndSettle();

    expect(find.text('Gün Sayacı'), findsOneWidget);

    final addButton = find.widgetWithIcon(FloatingActionButton, Icons.add);
    expect(addButton, findsOneWidget);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // EtkinlikEkleSayfasi has AppBar title 'Etkinlik Ekle'
    expect(find.text('Etkinlik Ekle'), findsOneWidget);
  });
}
