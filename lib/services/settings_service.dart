import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final int? questionCount;
  final bool randomOrder;
  final bool explanations;
  final bool forceDarkMode;

  const AppSettings({
    this.questionCount = 20,
    this.randomOrder = true,
    this.explanations = true,
    this.forceDarkMode = false,
  });

  AppSettings copyWith({
    int? questionCount,
    bool unlimited = false,
    bool? randomOrder,
    bool? explanations,
    bool? forceDarkMode,
  }) {
    return AppSettings(
      questionCount: unlimited ? null : (questionCount ?? this.questionCount),
      randomOrder: randomOrder ?? this.randomOrder,
      explanations: explanations ?? this.explanations,
      forceDarkMode: forceDarkMode ?? this.forceDarkMode,
    );
  }
}

class SettingsService {
  static const _countKey = 'question_count_v1';
  static const _randomKey = 'random_order_v1';
  static const _explanationsKey = 'explanations_v1';
  static const _darkKey = 'force_dark_v1';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCount = prefs.getInt(_countKey) ?? 20;
    return AppSettings(
      questionCount: storedCount == -1 ? null : storedCount,
      randomOrder: prefs.getBool(_randomKey) ?? true,
      explanations: prefs.getBool(_explanationsKey) ?? true,
      forceDarkMode: prefs.getBool(_darkKey) ?? false,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, settings.questionCount ?? -1);
    await prefs.setBool(_randomKey, settings.randomOrder);
    await prefs.setBool(_explanationsKey, settings.explanations);
    await prefs.setBool(_darkKey, settings.forceDarkMode);
  }
}
