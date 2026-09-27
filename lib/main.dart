import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'services/stats_service.dart';
import 'theme/app_theme.dart';

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

  ThemeMode get _themeMode => switch (_settings.themePreference) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Révision Arbitrage',
      themeMode: _themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: HomeScreen(
        settings: _settings,
        settingsService: widget.settingsService,
        stats: widget.statsService,
        onSettingsChanged: (settings) => setState(() => _settings = settings),
      ),
    );
  }
}
