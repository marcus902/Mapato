import 'package:flutter/services.dart';

/// Obfuscated API key is stored in native Kotlin code (compiled to bytecode).
/// This Dart file is kept only as the platform-channel bridge.
const _channel = MethodChannel('tz.mapato/prefs');

Future<String> getNativeApiKey() async {
  try {
    final key = await _channel.invokeMethod<String>('getNativeApiKey');
    return key ?? '';
  } catch (_) {
    return '';
  }
}
