import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_decoder_state.dart';
import '../../domain/usecases/decode_audio_message.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../data/services/audio_processing_service_impl.dart';

class AudioDecoderNotifier extends StateNotifier<AudioDecoderState> {
  final DecodeAudioMessage decodeUsecase;
  final AudioRepository audioRepository;

  AudioDecoderNotifier({
    required this.decodeUsecase,
    required this.audioRepository,
  }) : super(const AudioDecoderState());

  Future<void> pickFile() async {
    state = state.copyWith(status: 'Selecting file...');
    final pickEither = await audioRepository.pickAudioFilePath().run();
    if (pickEither.isLeft()) {
      state = state.copyWith(
        status:
            'File pick cancelled or error: ${pickEither.getLeft().toNullable()?.message ?? 'unknown'}',
      );
      return;
    }
    final path = pickEither.getRight().toNullable()!;
    state = state.copyWith(selectedFilePath: path, status: 'File selected');
  }

  Future<void> decodeMessage() async {
    final path = state.selectedFilePath;
    if (path == null) return;
    state = state.copyWith(isDecoding: true, status: 'Decoding...');
    final res = await decodeUsecase.executeFromPath(path).run();
    if (res.isLeft()) {
      final err = res.getLeft().toNullable()!;
      state = state.copyWith(
        isDecoding: false,
        status: 'Error: ${err.message}',
      );
      return;
    }
    final decoded = res.getRight().toNullable()!;
    state = state.copyWith(
      isDecoding: false,
      decodedMessage: decoded,
      status: 'Decoded successfully',
    );
  }

  void clearFile() {
    state = state.copyWith(
      selectedFilePath: null,
      decodedMessage: null,
      status: 'Idle',
    );
  }
}
