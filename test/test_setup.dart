import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialize test environment: mock SharedPreferences and common plugin MethodChannels.
Future<void> initTestEnvironment() async {
  // Mock SharedPreferences so code using it doesn't access platform storage.
  SharedPreferences.setMockInitialValues({});

  // Ensure Flutter test binding is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // Helper to set a no-op method call handler for a channel name.
  void _mockChannel(String name) {
    final channel = MethodChannel(name);
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      // Return null by default. Add specific returns if tests require them.
      return null;
    });
  }

  // Common plugin channel names (best-effort). These handlers harmlessly return null.
  const channelsToMock = <String>[
    'dexterous.com/flutter/local_notifications', // flutter_local_notifications
    'xyz.luan/audioplayers', // audioplayers
    'miguelruivo.flutter.plugins.filepicker', // file_picker (common variant)
    'miguelruivo.flutter.plugins.file_picker', // alternate
    'flutter_native_timezone', // timezone/native timezone plugin
  ];

  for (final name in channelsToMock) {
    _mockChannel(name);
  }
}
