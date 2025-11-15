# Flutter map setup

This file explains how to set up and run the Flutter map features (tile providers, API key, and permissions).

## Environment variable
Create a `.env` file in the `flutter/` folder (next to `pubspec.yaml`) with the StadiaMaps API key. The Flutter code reads the value using `flutter_dotenv`.

Example `.env` content:

```
STADIA_API_KEY=your_stadiamaps_api_key_here
```

You can use any key name you prefer, but the app expects `STADIA_API_KEY` by default. If you changed code to read a different name, adjust accordingly.

## Install packages
From the repository root, run:

```powershell
cd flutter
flutter pub get
```

## Run the app
Choose your device/emulator and run:

```powershell
cd flutter
flutter run -d <device-id>
```

## Android permissions
Add the following to `android/app/src/main/AndroidManifest.xml` inside the `<manifest>` / `<application>` section where appropriate:

```xml
<!-- location permission -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

If using `permission_handler`, follow its installation guide for additional Android config (Gradle settings and manifest setup).

## iOS permissions
In `ios/Runner/Info.plist` add the keys for location usage:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show nearby clinics on the map</string>
```

## Notes
- We pinned `http` to `^0.13.5` for compatibility with `flutter_map` in this project.
- If you see tile errors (blank tiles), confirm your `STADIA_API_KEY` is valid and check the tile provider fallbacks.
- For debugging, run the app in a device/emulator and watch the console for tile loading errors and network requests.
- If you want to use a different key name (for example `NEXT_PUBLIC_STADIAMAPS_API_KEY`), either rename the key in `.env` or update the Dart code to read that key.

If you'd like, I can also update `android`/`ios` config files automatically (manifest/Info.plist) and run `flutter pub get` for you interactively; tell me to proceed.
