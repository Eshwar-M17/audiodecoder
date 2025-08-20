import 'package:audiodecoder/domain/repositories/audio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/audio_processing_service_impl.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../data/repositories/frequency_repository_impl.dart';
import '../../domain/usecases/decode_audio_message.dart';
import '../../domain/repositories/frequency_repository.dart';

// Service
final audioProcessingServiceProvider = Provider<AudioProcessingService>((ref) {
  return AudioProcessingServiceImpl();
});

// Repositories
final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return AudioRepositoryImpl();
});

final frequencyMapProvider = Provider<Map<int, String>>((ref) {
  return {
    440: 'A', 350: 'B', 260: 'C', 474: 'D', 492: 'E', 401: 'F', 584: 'G', 553: 'H',
    582: 'I', 525: 'J', 501: 'K', 532: 'L', 594: 'M', 599: 'N', 528: 'O', 539: 'P',
    675: 'Q', 683: 'R', 698: 'S', 631: 'T', 628: 'U', 611: 'V', 622: 'W', 677: 'X',
    688: 'Y', 693: 'Z', 418: ' ',
  };
});

final frequencyRepositoryProvider = Provider<FrequencyRepository>((ref) {
  return FrequencyRepositoryImpl(ref.read(frequencyMapProvider));
});

// Usecase
final decodeAudioMessageProvider = Provider((ref) {
  return DecodeAudioMessage(
    audioRepository: ref.read(audioRepositoryProvider),
    audioProcessingService: ref.read(audioProcessingServiceProvider),
    frequencyRepository: ref.read(frequencyRepositoryProvider),
  );
});
