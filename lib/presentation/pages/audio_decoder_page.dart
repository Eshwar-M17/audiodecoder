import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/status_widget.dart';
import '../widgets/file_details_card.dart';
import '../widgets/enhanced_playback_controls.dart';
import '../widgets/decoded_message_section.dart';
import '../widgets/spectrogram_view.dart';
import 'package:dotted_border/dotted_border.dart';

class AudioDecoderPage extends ConsumerStatefulWidget {
  const AudioDecoderPage({super.key});

  @override
  ConsumerState<AudioDecoderPage> createState() => _AudioDecoderPageState();
}

class _AudioDecoderPageState extends ConsumerState<AudioDecoderPage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioDecoderNotifierProvider);
    final notifier = ref.read(audioDecoderNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'Audio Decoder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File selection or file details
              if (state.selectedFilePath == null) ...[
                // Upload section with dotted border
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: notifier.pickFile,
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: Radius.circular(12),
                          color: Colors.white,
                          dashPattern: [8, 4],
                          strokeWidth: 1,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.black26,

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF6366F1),
                                      const Color(0xFF4A90E2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isHovered
                                      ? Icons.upload_file
                                      : Icons.audio_file,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Upload Audio File',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Drag and drop your audio file here, or click to browse',
                                style: TextStyle(
                                  color: const Color(0xFFB0B0B0),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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

                // Start decoding button
                state.decodedMessage == null
                    ? Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF4A90E2),
                            ], // Blue → Teal
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: state.isDecoding
                              ? null
                              : notifier.decodeMessage,
                          icon: const Icon(Icons.memory, color: Colors.white),
                          label: const Text(
                            'Start Decoding',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // Make transparent
                            shadowColor: Colors.transparent, // Remove shadow
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                if (state.decodedMessage == null) const SizedBox(height: 16),

                // Status indicator
                if (state.isDecoding || state.status != 'Idle')
                  StatusWidget(
                    status: state.status,
                    isLoading: state.isDecoding,
                  ),
                if (state.isDecoding || state.status != 'Idle')
                  const SizedBox(height: 16),

                // Results section
                if (state.decodedMessage != null) ...[
                  Column(
                    children: [
                      DecodedMessageSection(
                        decodedMessage: state.decodedMessage!,
                      ),
                      const SizedBox(height: 16),
                      SpectrogramView(decodedMessage: state.decodedMessage!),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
