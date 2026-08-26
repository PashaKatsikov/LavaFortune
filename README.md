# Lava Fortune

A vertical, risk-and-reward volcanic drilling game built with Flutter.

Pick a route through the tunnel, balance heat against hull integrity, and
decide when to extract with your loot versus pushing deeper for rarer ore,
crystals and ancient relics.

## Getting started

```bash
flutter pub get
flutter run
```

## Release signing

Release builds are signed using `android/key.properties`, which is not
committed to version control. See `android/key.properties.example` for the
expected format, and keep the actual keystore (`.jks`) and its passwords
backed up somewhere safe outside of git — losing them means you can never
publish an update to the same app listing again.
