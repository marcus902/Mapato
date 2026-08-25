package tz.mapato.mapato

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Telephony
import androidx.core.app.NotificationCompat

class MapatoSmsService : Service() {

    private var observer: ContentObserver? = null
    private var lastId: Long = -1
    private val handler = Handler(Looper.getMainLooper())

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(1, buildNotification())
        registerObserver()
        return START_STICKY
    }

    private fun buildNotification(): Notification {
        val channel = NotificationChannel(
            "mapato_sms",
            "SMS Capture",
            NotificationManager.IMPORTANCE_MIN
        ).apply {
            description = "Required to keep Mapato listening for mobile money messages"
            setShowBadge(false)
        }
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        nm.createNotificationChannel(channel)
        return NotificationCompat.Builder(this, "mapato_sms")
            .setContentTitle("")
            .setContentText("")
            .setSmallIcon(applicationInfo.icon)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setOngoing(true)
            .build()
    }

    private fun registerObserver() {
        if (observer != null) return
        lastId = latestSmsId()
        observer = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean) {
                super.onChange(selfChange)
                handler.post { readLatest() }
            }
        }
        contentResolver.registerContentObserver(
            Telephony.Sms.CONTENT_URI, true, observer!!
        )
    }

    private fun latestSmsId(): Long {
        val c = contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            arrayOf(Telephony.Sms._ID),
            null, null,
            "${Telephony.Sms._ID} DESC LIMIT 1"
        )
        var id = -1L
        c?.use { if (it.moveToFirst()) id = it.getLong(0) }
        return id
    }

    private fun readLatest() {
        val c = contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            arrayOf(Telephony.Sms._ID, Telephony.Sms.ADDRESS, Telephony.Sms.BODY),
            null, null,
            "${Telephony.Sms._ID} DESC LIMIT 1"
        )
        c?.use {
            if (it.moveToFirst()) {
                val id = it.getLong(0)
                if (id != lastId) {
                    lastId = id
                    val address = it.getString(1)
                    val body = it.getString(2) ?: return
                    if (MnoFilters.isMnoSender(address)) {
                        NotificationBridge.emit(body)
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        observer?.let { contentResolver.unregisterContentObserver(it) }
        observer = null
        super.onDestroy()
    }
}
