import 'package:fpdart/fpdart.dart';
import 'dart:typed_data';
import '../../data/services/audio_processing_service_impl.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/frequency_repository.dart';
import '../entities/decoded_message.dart';
import '../entities/decoded_character.dart' as dc;

class DecodeAudioMessage {
  final AudioRepository audioRepository;
  final AudioProcessingService audioProcessingService;
  final FrequencyRepository frequencyRepository;

  DecodeAudioMessage({
    required this.audioRepository,
    required this.audioProcessingService,
    required this.frequencyRepository,
  });

  TaskEither<AudioFailure, DecodedMessage> executeFromPath(String filePath) {
    return TaskEither.tryCatch(() async {
      final bytesEither = await audioRepository.readFileBytes(filePath).run();
      if (bytesEither.isLeft()) throw bytesEither.getLeft().toNullable()!;
      final bytesList = bytesEither.getRight().toNullable()!;
      final bytes = Uint8List.fromList(bytesList);

      final wavEither = await audioProcessingService.parseWav(bytes).run();
      if (wavEither.isLeft()) throw wavEither.getLeft().toNullable()!;
      final wav = wavEither.getRight().toNullable()!;

      final monoEither = audioProcessingService.pcmToMonoFloat(wav.pcmBytes, wav.bitsPerSample, wav.numChannels);
      if (monoEither.isLeft()) throw monoEither.getLeft().toNullable()!;
      final samples = monoEither.getRight().toNullable()!;

      final segmentsEither = audioProcessingService.findAudioSegments(samples, wav.sampleRate);
      if (segmentsEither.isLeft()) throw segmentsEither.getLeft().toNullable()!;
      final segments = segmentsEither.getRight().toNullable()!;

      final decodedChars = <dc.DecodedCharacter>[];
      if (segments.isEmpty) {
        final fftEither = audioProcessingService.detectFrequencyFFT(samples, wav.sampleRate);
        if (fftEither.isLeft()) throw fftEither.getLeft().toNullable()!;
        final fft = fftEither.getRight().toNullable()!;
        final ch = frequencyRepository.mapFrequencyToCharacter(fft.bestFreq);
        if (ch == '?') throw DecodeFailure('No tones detected, bestFreq=\${fft.bestFreq}');
        decodedChars.add(dc.DecodedCharacter(character: ch, frequency: fft.bestFreq, startTimeMs: 0.0, endTimeMs: samples.length / wav.sampleRate * 1000.0, confidence: fft.confidence));
      } else {
        for (final seg in segments) {
          final segSamples = samples.sublist(seg.start, seg.end);
          final fftEither = audioProcessingService.detectFrequencyFFT(segSamples, wav.sampleRate);
          if (fftEither.isLeft()) continue;
          final fft = fftEither.getRight().toNullable()!;
          final mapped = frequencyRepository.mapFrequencyToCharacter(fft.bestFreq);
          final startMs = seg.start / wav.sampleRate * 1000.0;
          final endMs = seg.end / wav.sampleRate * 1000.0;
          decodedChars.add(dc.DecodedCharacter(character: mapped, frequency: fft.bestFreq, startTimeMs: startMs, endTimeMs: endMs, confidence: fft.confidence));
        }
      }

      if (decodedChars.isEmpty) throw DecodeFailure('No characters decoded');
      final message = decodedChars.map((c) => c.character).join();
      return DecodedMessage(message: message, characters: decodedChars);
    }, (err, st) {
      if (err is AudioFailure) return err as AudioFailure;
      return DecodeFailure(err.toString());
    });
  }
}
