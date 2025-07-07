package com.example.my_app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Bundle
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class NotificationsListenerService : NotificationListenerService() {
    companion object {
        var channel: MethodChannel? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName

        if (packageName.contains("spotify") || packageName.contains("music")) {
            val extras: Bundle? = sbn.notification.extras

            Log.d("LyricsifyNotif", "📦 Notification from $packageName")
            extras?.keySet()?.forEach { key ->
                Log.d("LyricsifyNotif", "🔑 Key: $key => ${extras.get(key)}")
            }

            val title = extras?.getCharSequence("android.title")?.toString()
            val text = extras?.getCharSequence("android.text")?.toString()
            val subText = extras?.getCharSequence("android.subText")?.toString()

            Log.d("LyricsifyNotif", "🎵 Extracted: title=$title, text=$text, subText=$subText")

            if (!title.isNullOrBlank() && !text.isNullOrBlank()) {
                val data = mapOf(
                    "track" to title,
                    "artist" to text,
                    "progress" to 0
                )
                channel?.invokeMethod("onMetadataChanged", data)
            } else {
                Log.w("LyricsifyNotif", "⚠️ Missing title or text — skipping send.")
            }
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        if (packageName.contains("spotify") || packageName.contains("music")) {
            Log.d("LyricsifyNotif", "🛑 Notification removed for $packageName")
            channel?.invokeMethod("onPlaybackStopped", null)
        }
    }
}
