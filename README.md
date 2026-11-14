# The Sky Science Academy ERP

Native Flutter Android app for academy operations, following the visual direction of the Sky Science Academy Lovable reference. It is offline-first and uses a device-local SQLite database.

## Current implementation

- Academy branded mobile shell with Home, Attendance, Students, Fees, and More navigation.
- SQLite schema for students, daily attendance, fee transactions, notices, staff, classes, and activity history.
- Student create, search, class filter, edit, profile, and archive flows. Admission numbers are unique.
- Daily class attendance with Present, Absent, Late, Leave, bulk Present, and a unique student/date constraint.
- Monthly fee balance view, partial payment entry, unique references, and transaction-safe payment logging.
- Dashboard totals are queried from local database records.
- Notice creation and importance flag.
- Deterministic tests for fee balances, payment validation, and attendance percentages.

## Build

Requirements: Flutter 3.32 or newer, Dart 3.11, Android SDK platform/build tools, and a Java 17 JDK.

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Expected APK output: `build/app/outputs/flutter-apk/app-release.apk`.

The package ID is `com.skyscienceacademy.sky`. The current Gradle release signing block uses the generated debug signing configuration. Configure the academy's private signing key before distributing a production-signed APK.

## Data and privacy

`sky_academy.db` is created under the Android app's private database directory. SQLite foreign keys and indexes are enabled. Dates use ISO-8601 strings; fee amounts are stored as whole Pakistani rupees. Records do not synchronize to other phones.

## Current limitations

This is an initial functional build, not yet the complete ERP in the supplied acceptance brief. Login, role permissions, password setup, dedicated class/subject management, staff editing, full admissions approval, exams/marks/results, PDFs/printing, reports, and validated backup/restore still need implementation. The academy logo asset was not present in the workspace, so the header uses a science crest symbol in the established purple palette. No demo students or invented financial statistics are seeded.

## Development notes

Database schema version is 1. Future schema changes should use additive migrations and preserve existing records. A primary academy device is assumed until an explicit synchronization design is requested.
