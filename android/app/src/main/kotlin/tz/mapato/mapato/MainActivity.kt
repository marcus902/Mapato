package tz.mapato.mapato

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val NOTIF_CHANNEL = "tz.mapato/notifications"
    private val SETTINGS_CHANNEL = "tz.mapato/settings"
    private val CAPTURE_CHANNEL = "tz.mapato/capture"
    private val PERMISSIONS_CHANNEL = "tz.mapato/permissions"
    private val NOTIFY_OUT_CHANNEL = "tz.mapato/notify"
    private val PREFS_CHANNEL = "tz.mapato/prefs"
    private val SMS_PERM_REQUEST = 1001
    private val NOTIFY_PERM_REQUEST = 1002
    private var smsPermissionResult: MethodChannel.Result? = null
    private var notifyPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIF_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    NotificationBridge.sink = events
                }

                override fun onCancel(arguments: Any?) {
                    NotificationBridge.sink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openNotificationSettings" -> {
                        try {
                            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", e.message, null)
                        }
                    }
                    "isNotificationListenerEnabled" -> {
                        result.success(isNotificationListenerEnabled())
                    }
                    "tryEnableNotificationListener" -> {
                        result.success(tryEnableNotificationListener())
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAPTURE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startSmsService" -> {
                        try {
                            startService(Intent(this, MapatoSmsService::class.java))
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("SMS_START_FAILED", e.message, null)
                        }
                    }
                    "stopSmsService" -> {
                        try {
                            stopService(Intent(this, MapatoSmsService::class.java))
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("SMS_STOP_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSIONS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkSmsPermission" -> {
                        val readGranted = ContextCompat.checkSelfPermission(
                            this, Manifest.permission.READ_SMS
                        ) == PackageManager.PERMISSION_GRANTED
                        val receiveGranted = ContextCompat.checkSelfPermission(
                            this, Manifest.permission.RECEIVE_SMS
                        ) == PackageManager.PERMISSION_GRANTED
                        result.success(readGranted && receiveGranted)
                    }
                    "requestSmsPermission" -> {
                        if (ContextCompat.checkSelfPermission(
                                this, Manifest.permission.READ_SMS
                            ) == PackageManager.PERMISSION_GRANTED
                        ) {
                            result.success(true)
                        } else {
                            smsPermissionResult = result
                            val perms = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                arrayOf(
                                    Manifest.permission.READ_SMS,
                                    Manifest.permission.RECEIVE_SMS
                                )
                            } else {
                                arrayOf(Manifest.permission.READ_SMS)
                            }
                            ActivityCompat.requestPermissions(this, perms, SMS_PERM_REQUEST)
                        }
                    }
                    "requestNotifyPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            if (ContextCompat.checkSelfPermission(
                                    this, Manifest.permission.POST_NOTIFICATIONS
                                ) == PackageManager.PERMISSION_GRANTED
                            ) {
                                result.success(true)
                            } else {
                                notifyPermissionResult = result
                                ActivityCompat.requestPermissions(
                                    this,
                                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                    NOTIFY_PERM_REQUEST
                                )
                            }
                        } else {
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFY_OUT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "showTransaction") {
                    val title = call.argument<String>("title") ?: "Mapato"
                    val body = call.argument<String>("body") ?: ""
                    showTransaction(title, body)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PREFS_CHANNEL)
            .setMethodCallHandler { call, result ->
                val prefs = getSharedPreferences("mapato", MODE_PRIVATE)
                when (call.method) {
                    "getBool" -> {
                        val key = call.argument<String>("key") ?: ""
                        val def = call.argument<Boolean>("default") ?: false
                        result.success(prefs.getBoolean(key, def))
                    }
                    "setBool" -> {
                        val key = call.argument<String>("key") ?: ""
                        val value = call.argument<Boolean>("value") ?: false
                        prefs.edit().putBoolean(key, value).apply()
                        result.success(null)
                    }
                    "getString" -> {
                        val key = call.argument<String>("key") ?: ""
                        val def = call.argument<String>("default") ?: ""
                        result.success(prefs.getString(key, def) ?: def)
                    }
                    "setString" -> {
                        val key = call.argument<String>("key") ?: ""
                        val value = call.argument<String>("value") ?: ""
                        prefs.edit().putString(key, value).apply()
                        result.success(null)
                    }
                    "getNativeApiKey" -> {
                        result.success(deobfuscateKey())
                    }
                    else -> result.notImplemented()
                }
            }

    }

    private fun isNotificationListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(
            contentResolver,
            "enabled_notification_listeners"
        ) ?: return false
        val wanted = ComponentName(this, MapatoNotificationService::class.java)
            .flattenToString()
        return flat.split(":").any { it.equals(wanted, ignoreCase = true) }
    }

    /**
     * On Android 14+ manually installed apps may not appear in the
     * notification-access settings list.  This method writes our
     * component directly into the secure setting so the system
     * recognises us as an enabled listener without user interaction.
     *
     * Returns true when the listener is now enabled (or was already).
     */
    private fun tryEnableNotificationListener(): Boolean {
        if (isNotificationListenerEnabled()) return true

        val cn = ComponentName(this, MapatoNotificationService::class.java)
            .flattenToString()

        // 1. Ensure the component itself is enabled at the package level
        try {
            packageManager.setComponentEnabledSetting(
                ComponentName(this, MapatoNotificationService::class.java),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        } catch (_: Exception) { }

        // 2. Try writing the component into enabled_notification_listeners
        //    This requires WRITE_SECURE_SETTINGS (granted via ADB).
        try {
            val existing = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: ""
            val parts = existing.split(":").filter { it.isNotEmpty() }
            if (parts.none { it.equals(cn, ignoreCase = true) }) {
                val updated = if (existing.isBlank()) cn else "$existing:$cn"
                Settings.Secure.putString(contentResolver, "enabled_notification_listeners", updated)
            }
        } catch (_: SecurityException) {
            // WRITE_SECURE_SETTINGS not granted — fall through to manual flow
        }

        return isNotificationListenerEnabled()
    }

    private fun showTransaction(title: String, body: String) {
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "mapato_txn",
                "Transaction alerts",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            nm.createNotificationChannel(channel)
        }
        val intent = Intent(this, MainActivity::class.java)
        val pi = android.app.PendingIntent.getActivity(
            this, 0, intent,
            android.app.PendingIntent.FLAG_IMMUTABLE or
                android.app.PendingIntent.FLAG_UPDATE_CURRENT
        )
        val notification = NotificationCompat.Builder(this, "mapato_txn")
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(pi)
            .setAutoCancel(true)
            .build()
        nm.notify(System.currentTimeMillis().toInt(), notification)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERM_REQUEST) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            smsPermissionResult?.success(granted)
            smsPermissionResult = null
        } else if (requestCode == NOTIFY_PERM_REQUEST) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            notifyPermissionResult?.success(granted)
            notifyPermissionResult = null
        }
    }

    /**
     * Obfuscated API key reconstruction.
     * The key is NOT stored as a plain string — it's split into byte-array
     * chunks that R8 will merge into the .data section, making extraction
     * significantly harder than a simple string grep on the APK.
     */
    private fun deobfuscateKey(): String {
        // Build the key from individual char codes so no full string literal exists
        val p1 = intArrayOf(103,115,107,95,79,54,97,120,69,74,51,86,74,98,51,67,70,119,49,110)
        val p2 = intArrayOf(54,68,100,88,87,71,100,121,98,51,70,89,98,54,107,116,118,79,116)
        val p3 = intArrayOf(117,112,99,85,107,103,85,53,118,82,79,66,118,86,48,121,119)
        val all = p1 + p2 + p3
        return String(all, 0, all.size)
    }
}
