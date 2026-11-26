# Limbloop

Daily stretching routine with reminders. Flutter, fully offline. See `PLAN.md`.

## Run

```sh
flutter pub get
flutter run                          # on a connected device or emulator
flutter analyze && flutter test
dart run build_runner build          # after changing Drift tables
dart run tool/fetch_exercises.dart   # refresh the bundled exercises and images
```

Android builds: `android/gradle.properties` allows Gradle an 8 GB heap. On a
smaller machine, lower it for one build:

```sh
GRADLE_OPTS='-Dorg.gradle.jvmargs="-Xmx2G -XX:MaxMetaspaceSize=768m"' flutter build apk
```

Release builds need JDK 21 (`JAVA_HOME`): on JDK 17, Android lint crashes in
`:image_picker_android:lintVitalAnalyzeRelease`.
