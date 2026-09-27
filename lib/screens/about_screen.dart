import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos & installation')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                'Révision Arbitrage',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Une application simple pour réviser les motifs de la Loi 12 : '
                'coup franc direct, coup franc indirect, carton jaune et carton rouge.',
              ),
              const SizedBox(height: 20),
              const _InfoCard(
                icon: Icons.android_rounded,
                title: 'Android',
                text:
                    'Télécharge le fichier APK depuis la dernière Release GitHub puis ouvre-le sur le téléphone. Android peut demander l’autorisation d’installer une application provenant du navigateur.',
              ),
              const SizedBox(height: 12),
              const _InfoCard(
                icon: Icons.apple_rounded,
                title: 'iPhone / iPad',
                text:
                    'La version web fonctionne dans Safari. Pour l’avoir comme une application : ouvrir le site, toucher Partager, puis Ajouter à l’écran d’accueil. Une vraie version App Store pourra être publiée plus tard via un build iOS signé.',
              ),
              const SizedBox(height: 12),
              const _InfoCard(
                icon: Icons.language_rounded,
                title: 'Navigateur',
                text:
                    'La version web est responsive et garde les statistiques dans le stockage local du navigateur. Aucun compte n’est nécessaire.',
              ),
              const SizedBox(height: 24),
              Text('Données & règles', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'La base de questions est versionnée par saison et séparée du code. '
                'Elle peut donc être corrigée quand les Lois du Jeu évoluent. '
                'L’application est un outil de révision : les Lois du Jeu IFAB et les consignes officielles de formation font foi.',
              ),
              const SizedBox(height: 16),
              const Text('Base actuelle : saison 2026-2027 · 39 motifs.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
