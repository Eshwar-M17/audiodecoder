import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/audio_repository.dart';
import '../services/audio_processing_service_impl.dart';
import 'package:file_picker/file_picker.dart';

class AudioRepositoryImpl implements AudioRepository {
  @override
  TaskEither<AudioFailure, String> pickAudioFilePath() {
    return TaskEither.tryCatch(() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav'],
      );
      if (result == null || result.files.isEmpty) throw ParseFailure('No file chosen');
      final p = result.files.single.path;
      if (p == null) throw ParseFailure('No file path');
      return p;
    }, (err, st) {
      if (err is AudioFailure) return err;
      return ParseFailure(err.toString());
    });
  }

  @override
  TaskEither<AudioFailure, List<int>> readFileBytes(String path) {
    return TaskEither.tryCatch(() async {
      final file = File(path);
      final bytes = await file.readAsBytes();
      return bytes.toList();
    }, (err, st) {
      if (err is AudioFailure) return err;
      return ParseFailure(err.toString());
    });
  }
}
