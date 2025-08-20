import 'package:fpdart/fpdart.dart';
import 'dart:typed_data';
import '../../data/services/audio_processing_service_impl.dart';

abstract class AudioRepository {
  TaskEither<AudioFailure, String> pickAudioFilePath();
  TaskEither<AudioFailure, List<int>> readFileBytes(String path);
}
