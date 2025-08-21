# Audio Decoder

Flutter app that decodes simple tone-based audio into text and visualizes playback.

- Clean Architecture (Domain / Data / Presentation)
- Riverpod for state management
- FFT-based signal extraction
- Waveform-based audio playback and Spectrogram heatmap

## Approach Taken

### Audio Processing Strategy
- **FFT Analysis**: Uses `fftea` package for Fast Fourier Transform to extract frequency components from audio samples
- **Tone Detection**: Implements frequency binning (10Hz intervals) to group similar frequencies and avoid duplicates
- **Time Segmentation**: Groups audio into 100ms time bins for consistent spectrogram visualization
- **Confidence Scoring**: Calculates intensity based on frequency match accuracy and signal strength

### UI/UX Design
- **Waveform Visualization**: Replaced traditional slider with interactive waveform using `audio_waveforms` package
- **Spectrogram Heatmap**: Implemented frequency vs. time visualization using `fl_heatmap` for better data representation
- **Responsive Layout**: Horizontal and vertical scrolling for large datasets, compact bin sizing for readability
- **Dark Theme**: Consistent color scheme matching modern app design patterns

## How Clean Architecture is Applied

### Domain Layer (`lib/domain/`)
- **Entities**: `DecodedMessage`, `DecodedCharacter` - Pure data models with no dependencies
- **Repositories**: Abstract interfaces (`AudioRepository`, `FrequencyRepository`) defining contracts
- **Use Cases**: `DecodeAudioMessage` - Business logic orchestration, single responsibility principle

### Data Layer (`lib/data/`)
- **Services**: `AudioProcessingService` - Core FFT and signal processing logic
- **Repository Implementations**: Concrete implementations of domain repository interfaces
- **Data Sources**: `AudioFileDataSource` - File system access and data retrieval
- **Dependency Inversion**: Data layer implements domain interfaces, not the other way around

### Presentation Layer (`lib/presentation/`)
- **Providers**: Riverpod-based state management with dependency injection
- **State Management**: `AudioDecoderNotifier` - Business logic coordination and state updates
- **UI Components**: Widgets separated by responsibility (playback, visualization, results)
- **Separation of Concerns**: Each widget handles specific UI functionality

### Key Clean Architecture Principles
- **Dependency Rule**: Dependencies point inward (Presentation → Domain ← Data)
- **Independence**: Domain layer has no external dependencies
- **Testability**: Each layer can be tested independently
- **Flexibility**: Easy to swap implementations (e.g., different audio processing algorithms)

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

## Limitations

### Audio Processing Constraints
- **File Format**: Optimized for WAV files; other formats may require conversion
- **Frequency Range**: Limited to frequencies detectable by FFT with current window size
- **Signal Quality**: Requires clear, distinct tones; noisy audio may produce false positives
- **Real-time Processing**: Current implementation processes entire file; not suitable for streaming

### UI/UX Limitations
- **Large Files**: Very long audio files may cause performance issues with spectrogram rendering
- **Memory Usage**: FFT processing and heatmap generation can be memory-intensive for large datasets
- **Platform Support**: Some audio features may vary between Android, iOS, and web platforms

### Technical Limitations
- **FFT Window Size**: Fixed FFT parameters may not be optimal for all audio characteristics
- **Frequency Resolution**: 10Hz binning may miss subtle frequency variations
- **Time Precision**: 100ms time bins may not capture rapid frequency changes
- **Error Handling**: Limited error recovery for corrupted or unsupported audio files

## Future Improvements
- Adaptive FFT parameters based on audio characteristics
- Support for more audio formats and codecs
- Real-time audio processing and visualization
- Enhanced error handling and user feedback
- Performance optimizations for large audio files

