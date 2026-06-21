import 'dart:math';

/// Developer: Coach: Danilo
///
/// 6-character codes using an unambiguous alphabet (no 0/O, 1/I/L mixups)
/// so they're easy to read aloud or type on mobile.
class InviteCode {
  InviteCode._();

  static const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static final _rand = Random.secure();

  static String generate({int length = 6}) {
    return List.generate(
      length,
      (_) => _alphabet[_rand.nextInt(_alphabet.length)],
    ).join();
  }

  static bool isValidFormat(String code) {
    final cleaned = code.trim().toUpperCase();
    if (cleaned.length != 6) return false;
    return cleaned.split('').every((c) => _alphabet.contains(c));
  }

  static String normalize(String code) => code.trim().toUpperCase();
}
