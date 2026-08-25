package tz.mapato.mapato

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

object NotificationBridge {
    var sink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    fun emit(text: String) {
        mainHandler.post {
            sink?.success(text)
        }
    }
}
