# Building and signing the APK (local & CI)

This document explains how to build a Flutter APK locally and how to set up CI to produce a release (signed) or debug APK artifact.

Note: This repository contains a Flutter app skeleton under `app/flutter`. To build an Android APK you need a working Flutter SDK and Android SDK + platform tools.

## Local build (debug)

1. Install Flutter SDK (https://flutter.dev/docs/get-started/install)
2. Ensure Android SDK & a device/emulator are available and ANDROID_HOME is set.
3. Run:

```bash
cd app/flutter
flutter pub get
flutter build apk --debug
# output in build/app/outputs/flutter-apk/app-debug.apk
```

## Local build (release, unsigned)

```bash
cd app/flutter
flutter build apk --release --no-tree-shake-icons
# unsigned release APK: build/app/outputs/flutter-apk/app-release-unsigned.apk
```

## Generating a signing key (local)

Generate a keystore (local machine):

```bash
keytool -genkey -v -keystore ~/stand-release-key.jks -alias stand_key -keyalg RSA -keysize 2048 -validity 10000
```

Keep the password and alias safe. For CI, store the base64 of the keystore or store it encrypted in secrets.

## Configure Flutter / Gradle for signing

Place `stand-release-key.jks` either in `android/app` or another path and add the following to `android/key.properties`:

```
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=stand_key
storeFile=~/stand-release-key.jks
```

Then follow Flutter docs to set signingConfigs in `android/app/build.gradle` for release.

## CI build (GitHub Actions) — unsigned debug via workflow
- We include a sample workflow `.github/workflows/flutter-build.yml` that will use a preinstalled Flutter action, build an APK and store it as an artifact. For release builds you can provide secrets and keystore to sign the APK.

## Running on device
Install or push the APK to device/emulator:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---
If you want I can set up a GitHub Actions workflow for a release build and show how to pass keys securely (base64 encode keystore in secrets), or help with generating the Android project files if you don't have `android/` yet in `app/flutter` (those are created by `flutter create`).
