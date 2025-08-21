import 'package:flutter/material.dart';
import 'package:fl_heatmap/fl_heatmap.dart';
import '../../domain/entities/decoded_message.dart';

class SpectrogramView extends StatelessWidget {
  final DecodedMessage decodedMessage;

  const SpectrogramView({super.key, required this.decodedMessage});

  @override
  Widget build(BuildContext context) {
    // Generate spectrogram data from decoded message
    final spectrogramData = _generateSpectrogramData();

    if (spectrogramData.items.isEmpty) {
      return Card(
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No spectrogram data available',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequency Spectrogram',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heatmap
                        SizedBox(
                          width: (spectrogramData.columns.length * 20)
                              .toDouble()
                              .clamp(
                                MediaQuery.of(context).size.width,
                                double.infinity,
                              ),
                          height: (spectrogramData.rows.length * 25)
                              .toDouble()
                              .clamp(200.0, 1000.0),
                          child: Heatmap(heatmapData: spectrogramData),
                        ),
                        const SizedBox(height: 8),
                        // Decoded characters row (only)
                        Padding(
                          padding: const EdgeInsets.only(left: 56),
                          child: SizedBox(
                            width: (_getSortedTimeBins().length * 20)
                                .toDouble()
                                .clamp(
                                  MediaQuery.of(context).size.width - 56,
                                  double.infinity,
                                ),
                            child: Row(
                              children: _getSortedTimeBins().map((timeMs) {
                                final char = _charForTimeBin(timeMs);
                                return SizedBox(
                                  width: 20,
                                  child: Text(
                                    char,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  HeatmapData _generateSpectrogramData() {
    if (decodedMessage.characters.isEmpty) {
      return HeatmapData(rows: [], columns: [], items: []);
    }

    // Group frequencies into bins to avoid duplicates
    final frequencyBins = <double, List<double>>{};
    for (final char in decodedMessage.characters) {
      // Round frequency to nearest 10Hz bin
      final bin = ((char.frequency / 10).round() * 10).toDouble();
      frequencyBins.putIfAbsent(bin, () => []).add(char.frequency);
    }

    final frequencies = frequencyBins.keys.toList()..sort();

    // Group time slices to avoid too many columns
    final timeBins = <double, List<double>>{};
    for (final char in decodedMessage.characters) {
      // Round time to nearest 100ms bin
      final bin = ((char.startTimeMs / 100).round() * 100).toDouble();
      timeBins.putIfAbsent(bin, () => []).add(char.startTimeMs);
    }

    final timeSlices = timeBins.keys.toList()..sort();

    // Generate heatmap items
    final items = <HeatmapItem>[];

    for (int freqIndex = 0; freqIndex < frequencies.length; freqIndex++) {
      for (int timeIndex = 0; timeIndex < timeSlices.length; timeIndex++) {
        final frequencyBin = frequencies[freqIndex];
        final timeBin = timeSlices[timeIndex];

        // Find characters that fall within this frequency and time bin
        double maxIntensity = 0.0;
        for (final char in decodedMessage.characters) {
          final freqDiff = (char.frequency - frequencyBin).abs();
          final timeDiff = (char.startTimeMs - timeBin).abs();

          if (freqDiff <= 10 && timeDiff <= 100) {
            // Character falls within this bin
            maxIntensity = maxIntensity < char.confidence
                ? char.confidence
                : maxIntensity;
          }
        }

        items.add(
          HeatmapItem(
            value: maxIntensity,
            unit: 'confidence',
            xAxisLabel: '', // hide built-in x labels; we render our own below
            yAxisLabel: '${frequencyBin.toStringAsFixed(0)}Hz',
          ),
        );
      }
    }

    return HeatmapData(
      rows: frequencies.map((f) => '${f.toStringAsFixed(0)}Hz').toList(),
      columns: List<String>.filled(timeSlices.length, ''),
      items: items,
    );
  }

  List<double> _getSortedTimeBins() {
    final timeBins = <double>{};
    for (final char in decodedMessage.characters) {
      final timeBin = ((char.startTimeMs / 100).round() * 100).toDouble();
      timeBins.add(timeBin);
    }
    final list = timeBins.toList()..sort();
    return list;
  }

  String _charForTimeBin(double timeMs) {
    final timeBin = ((timeMs / 100).round() * 100).toDouble();
    final buffer = StringBuffer();
    for (final char in decodedMessage.characters) {
      final bin = ((char.startTimeMs / 100).round() * 100).toDouble();
      if (bin == timeBin) {
        buffer.write(char.character);
      }
    }
    return buffer.toString();
  }
}
