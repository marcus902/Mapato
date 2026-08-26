package tz.mapato.mapato

import android.content.SharedPreferences
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class MapatoNotificationService : NotificationListenerService() {

    private val defaultPackages = setOf(
        "com.vodacom.mpesa",        // M-Pesa (Vodacom)
        "tz.tigo.mfsapp",           // Mixx by Yas (formerly Tigo Pesa)
        "com.tigo.pesa",            // legacy Tigo Pesa app (some devices)
        "com.airtel.money",         // Airtel Money
        "com.halopesa.eu",          // HaloPesa (Halotel / Viettel)
        "tz.co.halo.halopesa",      // legacy HaloPesa package
        "com.azampesa",             // AzamPesa
    )

    private val prefs: SharedPreferences
        get() = getSharedPreferences("mapato", MODE_PRIVATE)

    /// Returns the set of packages to capture, or null when "capture all apps"
    /// is enabled. Falls back to the built-in defaults when nothing is stored.
    private fun allowedPackages(): Set<String>? {
        val sp = prefs
        val captureAll = sp.getBoolean("capture_all", false)
        if (captureAll) return null
        val csv = sp.getString("capture_packages", "") ?: ""
        if (csv.isBlank()) return defaultPackages
        return csv.split(",").map { it.trim() }.filter { it.isNotEmpty() }.toSet()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return
        val pkg = sbn.packageName ?: return
        val allowed = allowedPackages()
        if (allowed != null && pkg !in allowed) return

        val extras: Bundle = sbn.notification.extras ?: return
        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        val bigText = extras.getCharSequence("android.bigText")?.toString() ?: ""
        val combined = "$title\n$text\n$bigText"

        if (combined.isBlank()) return

        // Operator apps are trusted outright. For any other app (e.g. the SMS
        // app showing a message, or a chat app), only capture when the sender
        // clearly looks like a mobile-money source — so personal chatter is
        // never recorded as a transaction.
        if (!MnoFilters.isMnoPackage(pkg) && !MnoFilters.isMnoSender(title)) return

        NotificationBridge.emit(combined)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {}
}
