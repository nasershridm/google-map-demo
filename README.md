# دندن (DNDN) - GPS Tracking & Incident Reporting App

A production-grade Flutter application for real-time GPS route tracking, background foreground services, offline trip persistence with SQLite, and incident reporting (Police / Accident / Traffic).

---

## 🛠️ Project Setup & Prerequisites

### 1. Flutter SDK
- Flutter SDK **3.32.4** (Dart **3.8.1**)

### 2. Google Maps Android API Key Configuration
For security, the Google Maps API key is **not committed** to the repository.

1. Locate or create your local configuration file at:
   ```text
   android/local.properties
   ```
   *(You can copy from `android/local.properties.example`)*

2. Add your Google Maps Android API key:
   ```properties
   MAPS_API_KEY=YOUR_ACTUAL_GOOGLE_MAPS_API_KEY
   ```

3. Gradle automatically injects `${MAPS_API_KEY}` into `AndroidManifest.xml` via `manifestPlaceholders` at build time.

> **Security Note**: `android/local.properties` is listed in `.gitignore` and must never be committed to version control.

---

## 🔒 Google Cloud API Key Best Practices
To ensure production security:
- Restrict your API key in Google Cloud Console to **Android apps only**.
- Add your package name: `com.example.dndn`
- Add your SHA-1 certificate fingerprint:
  ```bash
  # Debug SHA-1
  cd android && ./gradlew signingReport
  ```
- Limit API access exclusively to **Maps SDK for Android**.

---

## 🚀 Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected Android device/emulator
flutter run
```

---

## 🧪 Running Tests & Analyzer

```bash
# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test
```
