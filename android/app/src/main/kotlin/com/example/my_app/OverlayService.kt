package com.example.my_app


import android.app.Service
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.*
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.core.app.NotificationCompat

const val ACTION_UPDATE_LYRICS = "com.example.my_app.UPDATE_LYRICS"

class OverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var textView: TextView? = null

    private val lyricsUpdateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val updatedText = intent?.getStringExtra("text") ?: return
            Log.d("OverlayService", "Received updated lyrics: $updatedText")
            textView?.text = updatedText
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("OverlayService", "onCreate called")

        createNotificationChannel()
        val notification = NotificationCompat.Builder(this, "overlay_channel")
            .setContentTitle("Lyricsify Overlay Running")
            .setContentText("Showing lyrics over screen")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()

        startForeground(1, notification)

        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.overlay_layout, null)
        textView = overlayView?.findViewById(R.id.overlay_text)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        windowManager?.addView(overlayView, params)

        // Register broadcast receiver
        val filter = IntentFilter("UPDATE_LYRICS")
        registerReceiver(lyricsUpdateReceiver, filter)

        Log.d("OverlayService", "Overlay created and added to window")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val text = intent?.getStringExtra("text") ?: "Lyrics"
        textView?.let {
            it.post {
                it.text = text
            }
        }
        Log.d("OverlayService", "onStartCommand called with text: $text")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        if (overlayView != null) {
            windowManager?.removeView(overlayView)
            Log.d("OverlayService", "Overlay removed from window")
        }
        //  Unregister receiver
        unregisterReceiver(lyricsUpdateReceiver)
        Log.d("OverlayService", "BroadcastReceiver unregistered")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                "overlay_channel",
                "Overlay Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}
