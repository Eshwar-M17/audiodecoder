class DecodedCharacter {
  final String character;
  final double frequency;
  final double startTimeMs;
  final double endTimeMs;
  final double confidence;
  const DecodedCharacter({
    required this.character,
    required this.frequency,
    required this.startTimeMs,
    required this.endTimeMs,
    required this.confidence,
  });
}
