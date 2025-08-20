import 'package:flutter/material.dart';
import '../../domain/entities/decoded_message.dart';

class TimeFrequencyView extends StatelessWidget {
  final DecodedMessage decoded;
  const TimeFrequencyView({super.key, required this.decoded});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (decoded.characters.isEmpty) {
          return const Center(child: Text('No decoded tones'));
        }
        final minFreq = decoded.characters.map((c) => c.frequency).reduce((a, b) => a < b ? a : b);
        final maxFreq = decoded.characters.map((c) => c.frequency).reduce((a, b) => a > b ? a : b);
        final minT = decoded.characters.map((c) => c.startTimeMs).reduce((a, b) => a < b ? a : b);
        final maxT = decoded.characters.map((c) => c.endTimeMs).reduce((a, b) => a > b ? a : b);

        double xOf(double tMs) => ((tMs - minT) / (maxT - minT + 1e-6)) * width;
        double yOf(double f) => height - ((f - minFreq) / (maxFreq - minFreq + 1e-6)) * height;

        return CustomPaint(
          painter: _TimeFreqPainter(
            boxes: decoded.characters.map((c) {
              final x1 = xOf(c.startTimeMs);
              final x2 = xOf(c.endTimeMs);
              final y = yOf(c.frequency);
              return _ToneBox(rect: Rect.fromLTWH(x1, y - 10, (x2 - x1).clamp(2, width), 20), label: c.character);
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ToneBox {
  final Rect rect;
  final String label;
  _ToneBox({required this.rect, required this.label});
}

class _TimeFreqPainter extends CustomPainter {
  final List<_ToneBox> boxes;
  _TimeFreqPainter({required this.boxes});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF7F7F7);
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    const gridLines = 6;
    for (int i = 1; i < gridLines; i++) {
      final y = size.height * i / gridLines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final boxPaint = Paint()..color = const Color(0xFF90CAF9);
    final borderPaint = Paint()
      ..color = const Color(0xFF1E88E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final b in boxes) {
      canvas.drawRRect(RRect.fromRectAndRadius(b.rect, const Radius.circular(4)), boxPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(b.rect, const Radius.circular(4)), borderPaint);
      textPainter.text = TextSpan(text: b.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
      textPainter.layout(minWidth: 0, maxWidth: b.rect.width - 4);
      final tp = Offset(b.rect.left + 4, b.rect.center.dy - textPainter.height / 2);
      textPainter.paint(canvas, tp);
    }
  }

  @override
  bool shouldRepaint(covariant _TimeFreqPainter oldDelegate) => oldDelegate.boxes != boxes;
}



