import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final ValueNotifier<AppSettings> appSettings = ValueNotifier<AppSettings>(
  const AppSettings(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storedTheme = ThemeMode.values[prefs.getInt('app_theme_index') ?? ThemeMode.system.index];
  final storedLocaleCode = prefs.getString('app_locale_code') ?? 'tr';

  appSettings.value = AppSettings(
    themeMode: storedTheme,
    locale: Locale(storedLocaleCode),
  );

  runApp(const GunSayerApp());
}

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('tr'),
  });

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme_index', themeMode.index);
    await prefs.setString('app_locale_code', locale.languageCode);
  }
}

class AppLocale {
  static const List<Locale> supportedLocales = [
    Locale('tr'),
    Locale('en'),
    Locale('de'),
    Locale('fr'),
    Locale('es'),
    Locale('ar'),
    Locale('ru'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('it'),
    Locale('pt'),
    Locale('hi'),
    Locale('uk'),
    Locale('fa'),
    Locale('id'),
    Locale('nl'),
    Locale('sv'),
    Locale('pl'),
    Locale('cs'),
    Locale('ro'),
    Locale('bg'),
    Locale('el'),
    Locale('he'),
    Locale('th'),
    Locale('vi'),
    Locale('hu'),
    Locale('fi'),
    Locale('da'),
    Locale('no'),
    Locale('sr'),
    Locale('sl'),
    Locale('hr'),
    Locale('et'),
    Locale('lv'),
    Locale('lt'),
    Locale('sk'),
    Locale('ms'),
  ];

  static const Map<String, String> languageNames = {
    'tr': 'Türkçe',
    'en': 'English',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'ar': 'العربية',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'it': 'Italiano',
    'pt': 'Português',
    'hi': 'हिन्दी',
    'uk': 'Українська',
    'fa': 'فارسی',
    'id': 'Bahasa Indonesia',
    'nl': 'Nederlands',
    'sv': 'Svenska',
    'pl': 'Polski',
    'cs': 'Čeština',
    'ro': 'Română',
    'bg': 'Български',
    'el': 'Ελληνικά',
    'he': 'עברית',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
    'hu': 'Magyar',
    'fi': 'Suomi',
    'da': 'Dansk',
    'no': 'Norsk',
    'sr': 'Srpski',
    'sl': 'Slovenščina',
    'hr': 'Hrvatski',
    'et': 'Eesti',
    'lv': 'Latviešu',
    'lt': 'Lietuvių',
    'sk': 'Slovenčina',
    'ms': 'Bahasa Melayu',
  };

  static String getName(String languageCode) {
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }
}

class Etkinlik {
  final String id;
  final String baslik;
  final DateTime tarih;
  final String? muzikYolu;

  Etkinlik(this.baslik, this.tarih, {String? id, this.muzikYolu})
      : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'baslik': baslik,
        'tarih': tarih.toIso8601String(),
        'muzikYolu': muzikYolu,
      };

  factory Etkinlik.fromJson(Map<String, dynamic> json) {
    return Etkinlik(
      json['baslik'] as String,
      DateTime.parse(json['tarih'] as String),
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      muzikYolu: json['muzikYolu'] as String?,
    );
  }
}

class GunSayerApp extends StatelessWidget {
  final bool disablePlatformPlugins;
  const GunSayerApp({super.key, this.disablePlatformPlugins = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: appSettings,
      builder: (context, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gün Sayacı',
          locale: settings.locale,
          supportedLocales: AppLocale.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          themeMode: settings.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
          ),
          home: AnaSayfa(disablePlatformPlugins: disablePlatformPlugins),
        );
      },
    );
  }
}

class AnaSayfa extends StatefulWidget {
  final bool disablePlatformPlugins;
  const AnaSayfa({super.key, this.disablePlatformPlugins = false});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  DateTime secilenTarih = DateTime(2026, 1, 1);
  List<Etkinlik> _etkinlikler = [];
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (!widget.disablePlatformPlugins) {
      _bildirimleriBaslat();
    }
    _etkinlikleriYukle();
  }

  Future<void> _ayarlarAc() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AyarlarSayfasi()),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  List<Etkinlik> get _siraliEtkinlikler {
    final sirali = [..._etkinlikler];
    sirali.sort((a, b) => a.tarih.compareTo(b.tarih));
    return sirali;
  }

  Future<void> _bildirimleriBaslat() async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(initializationSettings);
    } catch (_) {
      // Test ortamında veya platform desteği yoksa sessizce devam et.
    }
  }

  Future<void> _etkinlikBildiriminiPlanla(Etkinlik etkinlik) async {
    try {
      final id = etkinlik.tarih.millisecondsSinceEpoch.remainder(1000000000).abs();
      final zaman = tz.TZDateTime(
        tz.local,
        etkinlik.tarih.year,
        etkinlik.tarih.month,
        etkinlik.tarih.day,
        9,
        0,
      );

      const androidDetails = AndroidNotificationDetails(
        'gun_sayaci',
        'Gün Sayacı',
        channelDescription: 'Etkinlik günü bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.zonedSchedule(
        id,
        'Etkinlik zamanı geldi',
        '${etkinlik.baslik} için bugün gününüz geldi!',
        zaman,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Platform desteği yoksa bildirim planlanamaz.
    }
  }

  Future<void> _etkinlikleriYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kayitli = prefs.getStringList('etkinlikler') ?? [];

      final etkinlikler = <Etkinlik>[];
      for (final item in kayitli) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            etkinlikler.add(Etkinlik.fromJson(decoded));
          }
        } catch (_) {
          // Bozuk kayıtları atla.
        }
      }

      if (!mounted) return;
      setState(() {
        _etkinlikler = etkinlikler;
      });
      if (!widget.disablePlatformPlugins) {
        await _gelenEtkinlikleriKontrolEt();
      }
    } catch (_) {
      // Depolama erişiminde sorun olursa sessizce devam et.
    }
  }

  Future<void> _gelenEtkinlikleriKontrolEt() async {
    final bugun = _temizTarih(DateTime.now());
    final gelenler = _siraliEtkinlikler.where((etkinlik) {
      final tarih = _temizTarih(etkinlik.tarih);
      return tarih.isAtSameMomentAs(bugun) && (etkinlik.muzikYolu?.isNotEmpty ?? false);
    }).toList();

    for (final etkinlik in gelenler) {
      await _bildirimGoster(etkinlik);
      await _muzigiCal(etkinlik);
    }
  }

  Future<void> _bildirimGoster(Etkinlik etkinlik) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'gun_sayaci',
        'Gün Sayacı',
        channelDescription: 'Etkinlik günü bildirimleri',
        importance: Importance.max,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        etkinlik.tarih.millisecondsSinceEpoch.remainder(1000000000),
        'Etkinlik zamanı geldi',
        '${etkinlik.baslik} için bugün gününüz geldi!',
        notificationDetails,
      );
    } catch (_) {
      // Platform desteği yoksa bildirim gösterilemez.
    }
  }

  Future<void> _muzigiCal(Etkinlik etkinlik) async {
    final muzikYolu = etkinlik.muzikYolu;
    if (muzikYolu == null || muzikYolu.isEmpty) {
      return;
    }

    try {
      final dosya = File(muzikYolu);
      if (!dosya.existsSync()) {
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(muzikYolu));
    } catch (_) {
      // Müzik çalma desteklenmiyorsa sessizce devam et.
    }
  }

  Future<void> _etkinlikleriKaydet() async {
    try {
      for (final etkinlik in _etkinlikler) {
        await _etkinlikBildiriminiPlanla(etkinlik);
      }

      final prefs = await SharedPreferences.getInstance();
      final serialized = _etkinlikler
          .map((etkinlik) => jsonEncode(etkinlik.toJson()))
          .toList();
      await prefs.setStringList('etkinlikler', serialized);
    } catch (_) {
      // Kaydetme sırasında hata olursa görmezden gel.
    }
  }

  Future<void> _tarihSec() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: secilenTarih,
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() {
        secilenTarih = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  DateTime _temizTarih(DateTime tarih) => DateTime(tarih.year, tarih.month, tarih.day);

  Etkinlik? _aktifEtkinlik() {
    if (_siraliEtkinlikler.isEmpty) {
      return null;
    }

    final bugun = _temizTarih(DateTime.now());
    final gelecekler = _siraliEtkinlikler
        .where((etkinlik) => !_temizTarih(etkinlik.tarih).isBefore(bugun))
        .toList();

    if (gelecekler.isNotEmpty) {
      return gelecekler.first;
    }

    return _siraliEtkinlikler.last;
  }

  int _gunFarki({DateTime? tarih}) {
    final hedefTarih = _temizTarih(tarih ?? secilenTarih);
    final bugun = _temizTarih(DateTime.now());
    return hedefTarih.difference(bugun).inDays;
  }

  String _gunMetni(DateTime tarih) {
    final fark = _gunFarki(tarih: tarih);
    if (fark == 0) {
      return 'Bugün';
    }
    if (fark > 0) {
      return '$fark Gün kaldı';
    }
    return '${fark.abs()} Gün geçti';
  }

  Widget _gunRozeti(DateTime tarih) {
    final fark = _gunFarki(tarih: tarih);
    Color arkaPlan;
    Color yazi;
    String etiket;

    if (fark == 0) {
      arkaPlan = const Color(0xFF7C4DFF);
      yazi = Colors.white;
      etiket = 'Bugün';
    } else if (fark > 0) {
      arkaPlan = const Color(0xFF2ECC71);
      yazi = Colors.white;
      etiket = '$fark gün';
    } else {
      arkaPlan = const Color(0xFFE74C3C);
      yazi = Colors.white;
      etiket = '${fark.abs()} gün';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: arkaPlan,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        etiket,
        style: TextStyle(
          color: yazi,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _muzikAdi(String? muzikYolu) {
    if (muzikYolu == null || muzikYolu.isEmpty) {
      return 'Müzik yok';
    }
    return muzikYolu.split(Platform.pathSeparator).last;
  }

  String _tarihYazildi({DateTime? tarih}) {
    final hedefTarih = tarih ?? secilenTarih;
    return '${hedefTarih.day}.${hedefTarih.month}.${hedefTarih.year}';
  }

  Future<void> _etkinlikEkleSayfasiniAc() async {
    final sonuc = await Navigator.push<Etkinlik>(
      context,
      MaterialPageRoute(builder: (_) => const EtkinlikEkleSayfasi()),
    );

    if (sonuc != null) {
      setState(() {
        _etkinlikler.add(sonuc);
      _etkinlikler.sort((a, b) => a.tarih.compareTo(b.tarih));
    });
    await _etkinlikleriKaydet();
    }
  }

  Future<void> _etkinlikDuzenle(Etkinlik etkinlik) async {
    final sonuc = await Navigator.push<Etkinlik>(
    context,
    MaterialPageRoute(builder: (_) => EtkinlikEkleSayfasi(etkinlik: etkinlik)),
    );

    if (sonuc != null) {
    setState(() {
      final index = _etkinlikler.indexWhere((e) => e.id == sonuc.id);
      if (index >= 0) {
        _etkinlikler[index] = sonuc;
      } else {
        _etkinlikler.add(sonuc);
      }
      _etkinlikler.sort((a, b) => a.tarih.compareTo(b.tarih));
    });
    await _etkinlikleriKaydet();
    }
  }

  Future<void> _etkinlikSil(Etkinlik etkinlik) async {
    setState(() {
    _etkinlikler.removeWhere((e) => e.id == etkinlik.id);
    });
    await _etkinlikleriKaydet();
  }

  Future<void> _etkinlikleriGoster() async {
    await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final siraliEtkinlikler = _siraliEtkinlikler;

        return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(top: 10, left: 8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  splashRadius: 22,
                  icon: const Icon(Icons.arrow_back, size: 28, weight: 700, color: Color(0xFFFFD54F)),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              ),
            ),
            title: const Text('Etkinlikler'),
            toolbarHeight: 68,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: siraliEtkinlikler.isEmpty
                ? const Center(
                    child: Text(
                      'Kaydedilen etkinlik yok.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    itemCount: siraliEtkinlikler.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final etkinlik = siraliEtkinlikler[index];
                      return ListTile(
                        title: Text(etkinlik.baslik),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${etkinlik.tarih.day}.${etkinlik.tarih.month}.${etkinlik.tarih.year}'),
                            if (etkinlik.muzikYolu != null && etkinlik.muzikYolu!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Müzik: ${_muzikAdi(etkinlik.muzikYolu)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                            const SizedBox(height: 6),
                            _gunRozeti(etkinlik.tarih),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _etkinlikDuzenle(etkinlik),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _etkinlikSil(etkinlik),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      );
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    final aktifEtkinlik = _aktifEtkinlik();
    final aktifTarih = aktifEtkinlik?.tarih ?? secilenTarih;
    final metin = _gunMetni(aktifTarih);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Gün Sayacı', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _ayarlarAc,
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: _etkinlikleriGoster,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              child: const Icon(Icons.list),
            ),
            FloatingActionButton(
              onPressed: _etkinlikEkleSayfasiniAc,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Seçilen Tarihe Göre:',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.white12,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (aktifEtkinlik != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.celebration, color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      aktifEtkinlik.baslik,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            metin,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '(${_tarihYazildi(tarih: aktifTarih)})',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          if (aktifEtkinlik?.muzikYolu != null && aktifEtkinlik!.muzikYolu!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Müzik: ${_muzikAdi(aktifEtkinlik.muzikYolu)}',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _tarihSec,
                    child: Text('Tarih Seç: ${_tarihYazildi(tarih: aktifTarih)}', style: const TextStyle(color: Colors.white)),
                  ),
                  if (_siraliEtkinlikler.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Kaydedilen etkinlikler',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 320,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: _siraliEtkinlikler.map((etkinlik) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        etkinlik.baslik,
                                        style: const TextStyle(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      _gunRozeti(etkinlik.tarih),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${etkinlik.tarih.day}.${etkinlik.tarih.month}.${etkinlik.tarih.year}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AyarlarSayfasi extends StatefulWidget {
  const AyarlarSayfasi({super.key});

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  late ThemeMode _seciliTema;
  late Locale _seciliDil;

  @override
  void initState() {
    super.initState();
    final mevcut = appSettings.value;
    _seciliTema = mevcut.themeMode;
    _seciliDil = mevcut.locale;
  }

  Future<void> _kaydet() async {
    final yeniAyarlar = appSettings.value.copyWith(
      themeMode: _seciliTema,
      locale: _seciliDil,
    );
    appSettings.value = yeniAyarlar;
    await yeniAyarlar.save();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF121212), const Color(0xFF1C1C1E)]
                : [const Color(0xFFEAF2FF), const Color(0xFFF8F9FF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.palette_outlined, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tema',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text('Cihaz Teması')),
                          ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text('Açık')),
                          ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text('Koyu')),
                        ],
                        selected: {_seciliTema},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _seciliTema = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.language, color: Colors.purple),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Dil',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _seciliDil.languageCode,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          labelText: 'Dil Seçin',
                          prefixIcon: Icon(Icons.translate),
                        ),
                        items: AppLocale.supportedLocales.map((locale) {
                          return DropdownMenuItem<String>(
                            value: locale.languageCode,
                            child: Text(AppLocale.getName(locale.languageCode)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _seciliDil = Locale(value);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.info_outline, color: Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Uygulama', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Gün Sayacı v1.0.0', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _kaydet,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EtkinlikEkleSayfasi extends StatefulWidget {
  final Etkinlik? etkinlik;

  const EtkinlikEkleSayfasi({super.key, this.etkinlik});

  @override
  State<EtkinlikEkleSayfasi> createState() => _EtkinlikEkleSayfasiState();
}

class _EtkinlikEkleSayfasiState extends State<EtkinlikEkleSayfasi> {
  late final TextEditingController _baslikController;
  late DateTime _seciliTarih;
  String? _seciliMuzikYolu;

  @override
  void initState() {
    super.initState();
    _baslikController = TextEditingController(text: widget.etkinlik?.baslik ?? '');
    _seciliTarih = widget.etkinlik?.tarih ?? DateTime.now();
    _seciliMuzikYolu = widget.etkinlik?.muzikYolu;
  }

  Future<void> _tarihSec() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _seciliTarih,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _seciliTarih = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _muzikSec() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    final yol = result?.files.single.path;
    if (yol == null || yol.isEmpty) {
      return;
    }

    setState(() {
      _seciliMuzikYolu = yol;
    });
  }

  void _kaydet() {
    final baslik = _baslikController.text.trim();
    if (baslik.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Etkinlik adı girin.')),
      );
      return;
    }

    final etkinlik = Etkinlik(
      baslik,
      _seciliTarih,
      id: widget.etkinlik?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      muzikYolu: _seciliMuzikYolu,
    );
    Navigator.pop(context, etkinlik);
  }

  @override
  void dispose() {
    _baslikController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.etkinlik != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Etkinlik Düzenle' : 'Etkinlik Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _baslikController,
              decoration: const InputDecoration(
                labelText: 'Etkinlik adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tarih: ${_seciliTarih.day}.${_seciliTarih.month}.${_seciliTarih.year}',
                  ),
                ),
                TextButton.icon(
                  onPressed: _tarihSec,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Seç'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _seciliMuzikYolu == null || _seciliMuzikYolu!.isEmpty
                        ? 'Müzik seçilmedi'
                        : 'Müzik: ${_seciliMuzikYolu!.split(Platform.pathSeparator).last}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _muzikSec,
                  icon: const Icon(Icons.music_note),
                  label: const Text('Seç'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _kaydet,
                child: Text(isEdit ? 'Güncelle' : 'Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}