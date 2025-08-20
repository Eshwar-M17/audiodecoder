import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/audio_decoder_page.dart';
import 'presentation/providers/dependency_injection.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ensure providers initialized
    ref.read(audioProcessingServiceProvider);
    return MaterialApp(
      title: 'WAV Decoder Clean',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AudioDecoderPage(),
    );
  }
}
