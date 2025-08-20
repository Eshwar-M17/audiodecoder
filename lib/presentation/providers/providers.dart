import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dependency_injection.dart';
import 'audio_decoder_notifier.dart';
import 'audio_decoder_state.dart';

final audioDecoderNotifierProvider = StateNotifierProvider<AudioDecoderNotifier, AudioDecoderState>((ref) {
  return AudioDecoderNotifier(
    decodeUsecase: ref.read(decodeAudioMessageProvider),
    audioRepository: ref.read(audioRepositoryProvider),
  );
});
