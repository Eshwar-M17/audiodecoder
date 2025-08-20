# Audio Decoder (Clean Architecture)

This repository contains a refactored Flutter project implementing a WAV-to-text decoder using FFT.
It follows Clean Architecture (Domain / Data / Presentation) and uses `fpdart` for functional error handling.

## Structure
- `lib/domain` - Entities, repositories, use-cases
- `lib/data` - Services (WAV parser, FFT), repository implementations, datasources
- `lib/presentation` - Riverpod providers, state notifiers, UI pages and widgets
- `test` - Basic unit tests that generate synthetic sine waves

## How to use
1. `flutter pub get`
2. Open the project in your IDE (Android Studio / VS Code) under Flutter.
3. Run `flutter run` to launch the example UI.
4. Use the UI to pick a WAV file and decode.

## Notes
- This is a template codebase: tune segmentation and mapping tolerances for your data.
- Tests are included in `test/audio_processing_service_test.dart`.

