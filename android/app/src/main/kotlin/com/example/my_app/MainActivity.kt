package com.example.my_app

import android.content.Intent
import androidx.core.content.ContextCompat
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "overlay_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkAndRequestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        if (!Settings.canDrawOverlays(this)) {
                            Log.d("MainActivity", "Overlay permission not granted, opening settings")
                            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(intent)
                            result.success(false)
                            return@setMethodCallHandler
                        } else {
                            Log.d("MainActivity", "Overlay permission already granted")
                        }

                        try {
                            val enabledListeners = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: ""
                            if (!enabledListeners.contains(packageName)) {
                                Log.d("MainActivity", "Notification access not granted, opening settings")
                                val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                startActivity(intent)
                            }
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Failed to check notification listener access", e)
                        }

                        result.success(true)
                    } else {
                        result.success(true)
                    }
                }


                "startOverlay" -> {
                    val text = call.argument<String>("text") ?: "Lyrics"
                    Log.d("MainActivity", "Starting OverlayService with text: $text")
                    val intent = Intent(this, OverlayService::class.java)
                    intent.putExtra("text", text)
                    ContextCompat.startForegroundService(this, intent)
                    result.success(null)
                }

                "updateOverlay" -> {
                    val text = call.argument<String>("text") ?: ""
                    Log.d("MainActivity", "Sending update to OverlayService: $text")
                    val intent = Intent("UPDATE_LYRICS")
                    intent.putExtra("text", text)
                    sendBroadcast(intent)
                    result.success(null)
                }

                "stopOverlay" -> {
                    Log.d("MainActivity", "Stopping OverlayService")
                    stopService(Intent(this, OverlayService::class.java))
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        NotificationsListenerService.channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lyricsify.notification")
    }
}
