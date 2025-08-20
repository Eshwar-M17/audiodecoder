import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class AudioFileDataSourceImpl {
  Future<String?> pickFilePath() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['wav']);
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.path;
  }

  Future<Uint8List> readFileBytes(String path) async {
    return await File(path).readAsBytes();
  }
}
