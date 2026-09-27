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
      body: ListView(
        children: [
          ListTile(
            title: const Text('Nombre de questions'),
            trailing: DropdownButton<int>(
              value: _settings.questionCount ?? -1,
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
          SwitchListTile(
            title: const Text('Ordre aléatoire'),
            value: _settings.randomOrder,
            onChanged: (v) => _save(_settings.copyWith(randomOrder: v)),
          ),
          SwitchListTile(
            title: const Text('Afficher les explications'),
            value: _settings.explanations,
            onChanged: (v) => _save(_settings.copyWith(explanations: v)),
          ),
          SwitchListTile(
            title: const Text('Forcer le mode sombre'),
            subtitle: const Text('Désactivé : suit le thème du téléphone.'),
            value: _settings.forceDarkMode,
            onChanged: (v) => _save(_settings.copyWith(forceDarkMode: v)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Réinitialiser les statistiques'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Réinitialiser ?'),
                  content: const Text(
                    'Toutes les tentatives et les erreurs enregistrées seront supprimées.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await widget.stats.reset();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Statistiques réinitialisées.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
