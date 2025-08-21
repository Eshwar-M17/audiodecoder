# Audio Decoder

Flutter app that decodes simple tone-based audio into text and visualizes playback.

- Clean Architecture (Domain / Data / Presentation)
- Riverpod for state management
- FFT-based signal extraction
- Waveform-based audio playback and Spectrogram heatmap

## Features
- Pick an audio file and play/pause with enhanced controls
- Waveform seek/preview via `audio_waveforms`
- Frequency Spectrogram (heat map) via `fl_heatmap`
- Live status + decoded message, with one-tap copy

## Tech Stack
- Flutter 3
- Riverpod 2
- audioplayers (playback)
- audio_waveforms (waveform + player controller)
- fl_heatmap (spectrogram heat map)
- fftea (FFT)
- fpdart (functional types)

## Project Structure
- `lib/domain` – entities, repositories, use-cases
- `lib/data` – datasources and implementations (audio processing)
- `lib/presentation` – providers and UI widgets/pages
- `test` – unit and widget tests

## Getting Started
1. Install Flutter and a recent stable channel.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Usage
1. Tap "Upload Audio File" and pick a local file (WAV preferred).
2. Use the  playback controls to play/pause and adjust volume.
3. Seek using the waveform.
4. Tap "Start Decoding" to analyze and decode the message.
5. View results:
   - Decoded message card with copy button
   - Frequency Spectrogram heat map (rows = frequency bins, columns = time bins)
   - Characters labeled under the spectrogram X‑axis

