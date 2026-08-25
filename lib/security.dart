import 'dart:convert';

const _pinSalt = 'mapato-pin-v1';

/// Hashes a PIN with a fixed salt (FNV-1a 64-bit). This avoids storing the raw
/// PIN in plaintext on the device. It is not cryptographically strong, but is
/// enough to keep an optional app lock from leaking the code in shared prefs.
String hashPin(String pin) {
  var h = 0xcbf29ce484222325;
  final bytes = utf8.encode('$_pinSalt:$pin');
  for (final b in bytes) {
    h ^= b;
    h *= 0x100000001b3;
    h &= 0xffffffffffffffff;
  }
  return h.toRadixString(16).padLeft(16, '0');
}

bool verifyPinHash(String pin, String? storedHash) {
  if (storedHash == null || storedHash.isEmpty) return false;
  return hashPin(pin) == storedHash;
}
