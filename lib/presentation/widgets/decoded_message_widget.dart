import 'package:flutter/material.dart';
import '../../domain/entities/decoded_message.dart';

class DecodedMessageWidget extends StatelessWidget {
  final DecodedMessage decodedMessage;
  const DecodedMessageWidget({super.key, required this.decodedMessage});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Decoded message:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SelectableText(
          decodedMessage.message,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text('Details:'),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: decodedMessage.characters.length,
          separatorBuilder: (_, __) => const Divider(height: 8),
          itemBuilder: (context, i) {
            final c = decodedMessage.characters[i];
            return ListTile(
              dense: true,
              leading: Text('${i + 1}'),
              title: Text(
                'Char: ${c.character}  Freq: ${c.frequency.toStringAsFixed(1)} Hz',
              ),
              subtitle: Text(
                'Start: ${c.startTimeMs.toStringAsFixed(0)} ms  End: ${c.endTimeMs.toStringAsFixed(0)} ms  Confidence: ${c.confidence.toStringAsFixed(2)}',
              ),
            );
          },
        ),
      ],
    );
  }
}
