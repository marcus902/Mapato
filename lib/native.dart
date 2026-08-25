import 'package:flutter/services.dart';

const notifyChannel = MethodChannel('tz.mapato/notify');
const prefsChannel = MethodChannel('tz.mapato/prefs');
const settingsChannel = MethodChannel('tz.mapato/settings');
const permissionsChannel = MethodChannel('tz.mapato/permissions');

/// Returns true if the OS notification-listener service for this app is
/// actually enabled (Notification access granted by the user).
Future<bool> isNotificationListenerEnabled() async {
  try {
    final enabled = await settingsChannel
        .invokeMethod<bool>('isNotificationListenerEnabled');
    return enabled ?? false;
  } on PlatformException {
    return false;
  }
}

/// Show a local confirmation notification when a transaction is recorded.
Future<void> notifyTransaction(String title, String body) async {
  try {
    await notifyChannel.invokeMethod('showTransaction', {
      'title': title,
      'body': body,
    });
  } on PlatformException {
    // Notifications unavailable; ignore.
  }
}

Future<bool> getPrefBool(String key, [bool defaultVal = false]) async {
  try {
    final v = await prefsChannel.invokeMethod<bool>('getBool', {
      'key': key,
      'default': defaultVal,
    });
    return v ?? defaultVal;
  } on PlatformException {
    return defaultVal;
  }
}

Future<void> setPrefBool(String key, bool value) async {
  try {
    await prefsChannel.invokeMethod('setBool', {
      'key': key,
      'value': value,
    });
  } on PlatformException {
    // Ignore.
  }
}

Future<String> getPrefString(String key, [String defaultVal = '']) async {
  try {
    final v = await prefsChannel.invokeMethod<String>('getString', {
      'key': key,
      'default': defaultVal,
    });
    return v ?? defaultVal;
  } on PlatformException {
    return defaultVal;
  }
}

Future<void> setPrefString(String key, String value) async {
  try {
    await prefsChannel.invokeMethod('setString', {
      'key': key,
      'value': value,
    });
  } on PlatformException {
    // Ignore.
  }
}

/// Requests the POST_NOTIFICATIONS permission (Android 13+) so the app's own
/// confirmation/alert notifications can be shown. Returns the granted state.
Future<bool> requestPostNotificationPermission() async {
  try {
    final granted =
        await permissionsChannel.invokeMethod<bool>('requestNotifyPermission') ??
            false;
    return granted;
  } on PlatformException {
    return false;
  }
}

/// Requests READ_SMS + RECEIVE_SMS permissions via the Android runtime dialog.
Future<bool> requestSmsPermission() async {
  try {
    final granted =
        await permissionsChannel.invokeMethod<bool>('requestSmsPermission') ??
            false;
    return granted;
  } on PlatformException {
    return false;
  }
}


