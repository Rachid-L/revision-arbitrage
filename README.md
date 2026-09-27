# Révision Arbitrage

Application Flutter de révision destinée aux jeunes arbitres de football.

Elle permet de réviser quatre familles de motifs de la Loi 12 :

- coup franc direct (CFD) ;
- coup franc indirect (CFI) ;
- carton jaune (CJ) ;
- carton rouge (CR).

## Fonctionnalités

- 39 motifs dans une base JSON indépendante du code ;
- modes Tout réviser, CFD / CFI, Cartons et Mes erreurs ;
- correction immédiate et explications ;
- examen de 20 questions sans correction immédiate ;
- statistiques locales et scores par catégorie ;
- section À retravailler ;
- pondération des questions ratées pour les prochaines sessions ;
- thème système, clair ou sombre ;
- fonctionnement sans compte, sans publicité et sans collecte de données ;
- Android + navigateur depuis le même code Flutter.

## Version web

Une GitHub Action construit et déploie automatiquement la version web sur GitHub Pages à chaque push sur `master`.

URL prévue :

`https://rachid-l.github.io/revision-arbitrage/`

Sur iPhone/iPad, ouvrir le site dans Safari puis utiliser **Partager > Ajouter à l’écran d’accueil**.

## Android

Le workflow `Build Android release` produit automatiquement :

- `revision-arbitrage.apk` pour une installation directe sur Android ;
- `revision-arbitrage.aab` pour une future publication sur Google Play.

Les fichiers sont attachés à la Release GitHub `latest`.

## iOS / App Store

Le même projet Flutter peut être compilé pour iOS. La création d’un IPA distribuable et la publication TestFlight/App Store nécessitent cependant macOS, Xcode et une signature Apple Developer.

La V1 utilise donc la version web installable comme solution immédiate pour iPhone et iPad.

## Base de questions

La base se trouve dans :

`assets/data/questions.json`

Chaque entrée contient notamment :

```json
{
  "id": 17,
  "type": "reprise",
  "category": "CFI",
  "motif": "Faire obstacle à la progression d’un adversaire sans contact",
  "answer": "CFI",
  "explanation": "Sans contact, l’obstruction est sanctionnée par un coup franc indirect.",
  "season": "2026-2027",
  "source": "IFAB Loi 12.2"
}
```

La base peut être corrigée ou remplacée sans modifier la logique de quiz.

Validation locale :

```bash
python3 tool/validate_questions.py
```

> Cette application est un outil de révision. Les Lois du Jeu IFAB, les circulaires et les consignes officielles de formation font foi.

## Développement local

Prérequis : Flutter stable.

```bash
flutter pub get
flutter test
flutter analyze
flutter run -d chrome
```

### Android

Le dossier natif Android est généré automatiquement pour éviter de versionner du boilerplate :

```bash
./bootstrap_android.sh
flutter build apk --release
```

Sous Windows :

```powershell
.\bootstrap_android.ps1
flutter build apk --release
```

## Structure

```text
assets/data/questions.json    base de questions
lib/models/                  modèles
lib/services/                stockage, statistiques, moteur de quiz
lib/screens/                 écrans
lib/widgets/                 composants UI
lib/theme/                   thème visuel
web/                         configuration navigateur / PWA
.github/workflows/           builds automatiques
```

## Saison

Base initiale : **2026-2027**.

Le champ `season` a été prévu pour permettre des évolutions futures des Lois du Jeu.
