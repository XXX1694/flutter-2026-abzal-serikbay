# Mobile Application Development with Flutter I

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)

Weekly practice work for the university course "Mobile Application Development with Flutter I" (2026). Each week is a separate folder under `lib/`; weeks 3-6 are standalone Flutter projects.

## Weeks

| Week | Topic | What is built |
|------|-------|---------------|
| 02 | Dart language | Console program: abstract class, mixin, `sealed` class, enums, JSON parsing and null safety on a small library catalogue |
| 03 | Layout basics | Profile screen (header, info rows, asset image) |
| 04 | Stateful widgets | Tap card, two-way counter and stopwatch with `setState` |
| 05 | Responsive layout | Contact list that never overflows, in light and dark themes |
| 06 | Navigation | Students list, detail and edit screens with named routes, `onGenerateRoute`, route arguments, a result passed back and a confirm dialog |

## Screenshots

<p>
  <img src="lib/week03/screenshot.png" width="200" alt="Week 3">
  <img src="lib/week04/screenshot.png" width="200" alt="Week 4">
  <img src="lib/week05/screenshot_light.png" width="200" alt="Week 5 light">
  <img src="lib/week05/screenshot_dark.png" width="200" alt="Week 5 dark">
</p>
<p>
  <img src="lib/week06/screenshot_detail.png" width="200" alt="Week 6 detail">
  <img src="lib/week06/screenshot_dialog.png" width="200" alt="Week 6 dialog">
</p>

## Structure

```
lib/
├── week02/   # Dart-only: models, catalogue, shelf_state, main
├── week03/   # Flutter project: profile screen
├── week04/   # Flutter project: stateful widgets
├── week05/   # Flutter project: responsive contacts
└── week06/   # Flutter project: navigation (students)
```

## Getting started

```bash
# Week 2 (plain Dart)
dart run lib/week02/main.dart

# Weeks 3-6
cd lib/week06
flutter pub get
flutter run
```
