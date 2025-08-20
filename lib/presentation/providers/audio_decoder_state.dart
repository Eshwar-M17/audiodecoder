import '../../domain/entities/decoded_message.dart';

class AudioDecoderState {
  final String? selectedFilePath;
  final bool isDecoding;
  final DecodedMessage? decodedMessage;
  final String status;

  const AudioDecoderState({
    this.selectedFilePath,
    this.isDecoding = false,
    this.decodedMessage,
    this.status = 'Idle',
  });

  AudioDecoderState copyWith({
    String? selectedFilePath,
    bool? isDecoding,
    DecodedMessage? decodedMessage,
    String? status,
  }) {
    return AudioDecoderState(
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
      isDecoding: isDecoding ?? this.isDecoding,
      decodedMessage: decodedMessage ?? this.decodedMessage,
      status: status ?? this.status,
    );
  }
}
