import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { system, light, dark }

class AppSettings {
  final int? questionCount;
  final bool randomOrder;
  final bool explanations;
  final AppThemePreference themePreference;

  const AppSettings({
    this.questionCount = 20,
    this.randomOrder = true,
    this.explanations = true,
    this.themePreference = AppThemePreference.system,
  });

  AppSettings copyWith({
    int? questionCount,
    bool unlimited = false,
    bool? randomOrder,
    bool? explanations,
    AppThemePreference? themePreference,
  }) {
    return AppSettings(
      questionCount: unlimited ? null : (questionCount ?? this.questionCount),
      randomOrder: randomOrder ?? this.randomOrder,
      explanations: explanations ?? this.explanations,
      themePreference: themePreference ?? this.themePreference,
    );
  }
}

class SettingsService {
  static const _countKey = 'question_count_v1';
  static const _randomKey = 'random_order_v1';
  static const _explanationsKey = 'explanations_v1';
  static const _themeKey = 'theme_preference_v2';
  static const _legacyDarkKey = 'force_dark_v1';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCount = prefs.getInt(_countKey) ?? 20;
    final storedTheme = prefs.getString(_themeKey);
    final legacyDark = prefs.getBool(_legacyDarkKey) ?? false;

    final themePreference = storedTheme == null
        ? (legacyDark ? AppThemePreference.dark : AppThemePreference.system)
        : AppThemePreference.values.firstWhere(
            (value) => value.name == storedTheme,
            orElse: () => AppThemePreference.system,
          );

    return AppSettings(
      questionCount: storedCount == -1 ? null : storedCount,
      randomOrder: prefs.getBool(_randomKey) ?? true,
      explanations: prefs.getBool(_explanationsKey) ?? true,
      themePreference: themePreference,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, settings.questionCount ?? -1);
    await prefs.setBool(_randomKey, settings.randomOrder);
    await prefs.setBool(_explanationsKey, settings.explanations);
    await prefs.setString(_themeKey, settings.themePreference.name);
  }
}
