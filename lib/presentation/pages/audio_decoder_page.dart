import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/status_widget.dart';
import '../widgets/file_details_card.dart';
import '../widgets/enhanced_playback_controls.dart';
import '../widgets/decoded_message_section.dart';
import '../widgets/frequency_time_graph.dart';

class AudioDecoderPage extends ConsumerWidget {
  const AudioDecoderPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioDecoderNotifierProvider);
    final notifier = ref.read(audioDecoderNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Audio Decoder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File selection or file details
            if (state.selectedFilePath == null) ...[
              // Upload section
              Expanded(
                child: Center(
                  child: Card(
                    color: const Color(0xFF2D2D2D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF404040),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF4A90E2), Color(0xFF20B2AA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.audio_file,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Upload Audio File',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Drag and drop your audio file here, or click to browse',
                            style: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: notifier.pickFile,
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2D2D2D),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // File details card
              FileDetailsCard(
                filePath: state.selectedFilePath!,
                onRemove: () {
                  // Clear selected file
                  ref.read(audioDecoderNotifierProvider.notifier).clearFile();
                },
              ),
              const SizedBox(height: 16),

              // Enhanced playback controls
              EnhancedPlaybackControls(
                key: ValueKey(state.selectedFilePath!),
                filePath: state.selectedFilePath!,
              ),
              const SizedBox(height: 16),

              // Start decoding button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: state.isDecoding ? null : notifier.decodeMessage,
                  icon: const Icon(Icons.memory),
                  label: const Text('Start Decoding'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status indicator
              if (state.isDecoding || state.status != 'Idle')
                StatusWidget(status: state.status, isLoading: state.isDecoding),

              const SizedBox(height: 16),

              // Results section
              if (state.decodedMessage != null) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        DecodedMessageSection(
                          decodedMessage: state.decodedMessage!,
                        ),
                        const SizedBox(height: 16),
                        FrequencyTimeGraph(
                          decodedMessage: state.decodedMessage!,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
