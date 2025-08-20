import 'package:flutter/material.dart';
import '../../domain/entities/decoded_message.dart';

class FrequencyTimeGraph extends StatelessWidget {
  final DecodedMessage decodedMessage;

  const FrequencyTimeGraph({super.key, required this.decodedMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and legend
            Row(
              children: [
                const Text(
                  'Frequency Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A90E2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Frequency',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Graph container
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF404040),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _FrequencyTimePainter(decodedMessage: decodedMessage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyTimePainter extends CustomPainter {
  final DecodedMessage decodedMessage;

  _FrequencyTimePainter({required this.decodedMessage});

  @override
  void paint(Canvas canvas, Size size) {
    if (decodedMessage.characters.isEmpty) {
      _drawNoData(canvas, size);
      return;
    }

    final chars = [...decodedMessage.characters]
      ..sort((a, b) => a.startTimeMs.compareTo(b.startTimeMs));

    final minTime = chars.first.startTimeMs;
    final maxTime = chars.last.endTimeMs;
    final minFreq = chars
        .map((c) => c.frequency)
        .reduce((a, b) => a < b ? a : b);
    final maxFreq = chars
        .map((c) => c.frequency)
        .reduce((a, b) => a > b ? a : b);

    // Add padding for better visualization
    final freqRange = maxFreq - minFreq;
    final paddedMinFreq = minFreq - freqRange * 0.1;
    final paddedMaxFreq = maxFreq + freqRange * 0.1;

    // Draw grid
    _drawGrid(canvas, size, minTime, maxTime, paddedMinFreq, paddedMaxFreq);

    // Draw frequency line
    _drawFrequencyLine(
      canvas,
      size,
      chars,
      minTime,
      maxTime,
      paddedMinFreq,
      paddedMaxFreq,
    );

    // Draw character markers
    _drawCharacterMarkers(
      canvas,
      size,
      chars,
      minTime,
      maxTime,
      paddedMinFreq,
      paddedMaxFreq,
    );
  }

  void _drawNoData(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF666666)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'No frequency data available',
        style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double minTime,
    double maxTime,
    double minFreq,
    double maxFreq,
  ) {
    final gridPaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 1;

    // Vertical lines (time)
    for (int i = 0; i <= 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines (frequency)
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawFrequencyLine(
    Canvas canvas,
    Size size,
    List<dynamic> chars,
    double minTime,
    double maxTime,
    double minFreq,
    double maxFreq,
  ) {
    final linePaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();
    bool firstPoint = true;

    for (final char in chars) {
      final time = (char.startTimeMs + char.endTimeMs) / 2;
      final x = ((time - minTime) / (maxTime - minTime)) * size.width;
      final y =
          size.height -
          ((char.frequency - minFreq) / (maxFreq - minFreq)) * size.height;

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  void _drawCharacterMarkers(
    Canvas canvas,
    Size size,
    List<dynamic> chars,
    double minTime,
    double maxTime,
    double minFreq,
    double maxFreq,
  ) {
    final markerPaint = Paint()
      ..color = const Color(0xFF20B2AA)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final char in chars) {
      final time = (char.startTimeMs + char.endTimeMs) / 2;
      final x = ((time - minTime) / (maxTime - minTime)) * size.width;
      final y =
          size.height -
          ((char.frequency - minFreq) / (maxFreq - minFreq)) * size.height;

      // Draw marker circle
      canvas.drawCircle(Offset(x, y), 6, markerPaint);

      // Draw character label
      textPainter.text = TextSpan(
        text: char.character,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 20));
    }
  }

  @override
  bool shouldRepaint(covariant _FrequencyTimePainter oldDelegate) => false;
}
