import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'services/stats_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsService = SettingsService();
  final statsService = StatsService();
  final settings = await settingsService.load();
  await statsService.load();

  runApp(
    RevisionArbitrageApp(
      initialSettings: settings,
      settingsService: settingsService,
      statsService: statsService,
    ),
  );
}

class RevisionArbitrageApp extends StatefulWidget {
  final AppSettings initialSettings;
  final SettingsService settingsService;
  final StatsService statsService;

  const RevisionArbitrageApp({
    super.key,
    required this.initialSettings,
    required this.settingsService,
    required this.statsService,
  });

  @override
  State<RevisionArbitrageApp> createState() => _RevisionArbitrageAppState();
}

class _RevisionArbitrageAppState extends State<RevisionArbitrageApp> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2E6BE6);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Révision Arbitrage',
      themeMode: _settings.forceDarkMode ? ThemeMode.dark : ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF6F7FA),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(
        settings: _settings,
        settingsService: widget.settingsService,
        stats: widget.statsService,
        onSettingsChanged: (settings) => setState(() => _settings = settings),
      ),
    );
  }
}
