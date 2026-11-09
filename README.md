# TikTalk

A free, no-ads stopwatch and interval timer with voice announcements, by Seal Studios.

## Features

- Stopwatch with lap splits
- Countdown / interval timer
- Spoken voice announcements via `flutter_tts`
- Lap and run history, stored locally with `sqflite`
- Light/dark theming with configurable dial accent colors and face styles

## Supported platforms

- Android
- Web

## Getting started

```bash
flutter pub get
flutter run
```

### Code generation

This project uses `riverpod_generator` and `freezed` for providers and models. After changing an
annotated file, regenerate the `*.g.dart` / `*.freezed.dart` sources:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### App icons and splash screens

App icons and native splash screens are generated from `assets/icon/icon.png` using
[`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) and
[`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash). To regenerate the
Android and web icons/splash screens after changing the source image, update
`assets/icon/icon.png` and run:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
