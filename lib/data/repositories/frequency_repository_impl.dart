import '../../domain/repositories/frequency_repository.dart';
import 'dart:math';

class FrequencyRepositoryImpl implements FrequencyRepository {
  final Map<int, String> _map;
  FrequencyRepositoryImpl(this._map);

  @override
  Map<int, String> getFrequencyMapping() => _map;

  @override
  String mapFrequencyToCharacter(double frequency) {
    double bestDiff = double.infinity;
    String bestChar = '?';
    for (final entry in _map.entries) {
      final diff = (frequency - entry.key).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestChar = entry.value;
      }
    }
    final tol = max(12.0, 0.02 * frequency);
    return (bestDiff <= tol) ? bestChar : '?';
  }
}
