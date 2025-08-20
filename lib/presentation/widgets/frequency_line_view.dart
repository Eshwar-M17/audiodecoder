import 'package:flutter/material.dart';
import '../../domain/entities/decoded_message.dart';

class FrequencyLineView extends StatelessWidget {
  final DecodedMessage decoded;
  const FrequencyLineView({super.key, required this.decoded});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FrequencyLinePainter(decoded: decoded),
      willChange: false,
    );
  }
}

class _FrequencyLinePainter extends CustomPainter {
  final DecodedMessage decoded;
  _FrequencyLinePainter({required this.decoded});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF7F7F7);
    final border = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final axis = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      bg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      border,
    );

    if (decoded.characters.isEmpty) {
      return;
    }

    final chars = [...decoded.characters]
      ..sort((a, b) => a.startTimeMs.compareTo(b.startTimeMs));
    final minT = chars.first.startTimeMs;
    final maxT = chars.last.endTimeMs;
    double minF = chars.first.frequency;
    double maxF = chars.first.frequency;
    for (final c in chars) {
      if (c.frequency < minF) minF = c.frequency;
      if (c.frequency > maxF) maxF = c.frequency;
    }
    if (minF == maxF) {
      minF -= 1;
      maxF += 1;
    }

    // Baseline
    final baselineY = size.height - 14;
    canvas.drawLine(
      Offset(12, baselineY),
      Offset(size.width - 12, baselineY),
      axis,
    );

    // Build polyline points (time on x, freq normalized on y)
    double xOf(double t) =>
        12 + ((t - minT) / ((maxT - minT).abs() + 1e-6)) * (size.width - 24);
    double yOf(double f) {
      final frac = (f - minF) / ((maxF - minF).abs() + 1e-6);
      final top = 12;
      final bottom = baselineY - 8;
      return bottom - frac * (bottom - top);
    }

    final path = Path();
    for (int i = 0; i < chars.length; i++) {
      final c = chars[i];
      final tMid = (c.startTimeMs + c.endTimeMs) / 2.0;
      final p = Offset(xOf(tMid), yOf(c.frequency));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    // Stroke
    final stroke = Paint()
      ..color = const Color(0xFF1E88E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _FrequencyLinePainter oldDelegate) => false;
}
