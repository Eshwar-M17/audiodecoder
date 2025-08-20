import 'package:flutter/material.dart';
import 'dart:io';

class FileDetailsCard extends StatelessWidget {
  final String filePath;
  final VoidCallback? onRemove;

  const FileDetailsCard({super.key, required this.filePath, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;

    return Card(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF20B2AA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<FileStat>(
                    future: File(filePath).stat(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final size = _formatFileSize(snapshot.data!.size);
                        return Text(
                          '$size • WAV file',
                          style: const TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 14,
                          ),
                        );
                      }
                      return const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF404040),
                  shape: const CircleBorder(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
