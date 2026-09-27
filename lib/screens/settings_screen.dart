import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/stats_service.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings initial;
  final SettingsService service;
  final StatsService stats;
  final ValueChanged<AppSettings> onChanged;

  const SettingsScreen({
    super.key,
    required this.initial,
    required this.service,
    required this.stats,
    required this.onChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initial;
  }

  Future<void> _save(AppSettings value) async {
    setState(() => _settings = value);
    await widget.service.save(value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                'Révision',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Nombre de questions'),
                      subtitle: const Text('Utilisé pour les modes de révision classiques.'),
                      trailing: DropdownButton<int>(
                        value: _settings.questionCount ?? -1,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: 10, child: Text('10')),
                          DropdownMenuItem(value: 20, child: Text('20')),
                          DropdownMenuItem(value: 39, child: Text('39')),
                          DropdownMenuItem(value: -1, child: Text('Illimité')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          _save(
                            value == -1
                                ? _settings.copyWith(unlimited: true)
                                : _settings.copyWith(questionCount: value),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Ordre aléatoire'),
                      subtitle: const Text('Mélange les motifs à chaque session.'),
                      value: _settings.randomOrder,
                      onChanged: (v) => _save(_settings.copyWith(randomOrder: v)),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Afficher les explications'),
                      subtitle: const Text('Montre une explication après chaque réponse.'),
                      value: _settings.explanations,
                      onChanged: (v) => _save(_settings.copyWith(explanations: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Apparence',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: SegmentedButton<AppThemePreference>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemePreference.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('Système'),
                      ),
                      ButtonSegment(
                        value: AppThemePreference.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Clair'),
                      ),
                      ButtonSegment(
                        value: AppThemePreference.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Sombre'),
                      ),
                    ],
                    selected: {_settings.themePreference},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      _save(_settings.copyWith(themePreference: selection.first));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Données locales',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Réinitialiser les statistiques'),
                  subtitle: const Text('Supprime les tentatives, scores et erreurs enregistrés sur cet appareil.'),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Réinitialiser ?'),
                        content: const Text(
                          'Toutes les tentatives et les erreurs enregistrées seront supprimées.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annuler'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Réinitialiser'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await widget.stats.reset();
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Statistiques réinitialisées.')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
