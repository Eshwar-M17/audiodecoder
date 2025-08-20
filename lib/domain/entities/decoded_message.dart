import 'decoded_character.dart';
class DecodedMessage {
  final String message;
  final List<DecodedCharacter> characters;
  const DecodedMessage({
    required this.message,
    required this.characters,
  });
}
