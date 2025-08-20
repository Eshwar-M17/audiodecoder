import 'dart:math';
import 'package:audiodecoder/data/repositories/frequency_repository_impl.dart';
import 'package:test/test.dart';
import 'package:audiodecoder/data/services/audio_processing_service_impl.dart';

List<double> makeSine(int sampleRate, double freq, double secs) {
  final n = (sampleRate * secs).round();
  return List.generate(n, (i) => sin(2 * pi * freq * i / sampleRate));
}

void main() {
  final svc = AudioProcessingServiceImpl();
  test('detect 440Hz sine', () {
    final s = makeSine(44100, 440.0, 0.5);
    final resEither = svc.detectFrequencyFFT(s, 44100);
    expect(resEither.isRight(), true);
    final res = resEither.getRight().toNullable()!;
    expect((res.bestFreq - 440.0).abs() < 3.0, true);
  });

  test('mapping to A', () {
    final repo = FrequencyRepositoryImpl({
      440: 'A', 350: 'B', 260: 'C', 474: 'D', 492: 'E', 401: 'F',
      584: 'G', 553: 'H', 582: 'I', 525: 'J', 501: 'K', 532: 'L', 594: 'M', 599: 'N', 528: 'O',
      539: 'P', 675: 'Q', 683: 'R', 698: 'S', 631: 'T', 628: 'U', 611: 'V', 622: 'W', 677: 'X',
      688: 'Y', 693: 'Z', 418: ' '
    });
    final mapped = repo.mapFrequencyToCharacter(440.0);
    expect(mapped, 'A');
  });
}
