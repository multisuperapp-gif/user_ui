package com.example.msa_user_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentResolver
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createBookingUpdatesNotificationChannel()
    }

    private fun createBookingUpdatesNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val soundUri = Uri.parse(
            "${ContentResolver.SCHEME_ANDROID_RESOURCE}://$packageName/raw/skins_theme_short"
        )
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val channel = NotificationChannel(
            "booking_updates",
            "Booking updates",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Plays a short sound for important labour booking updates."
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 180, 120, 180)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setSound(soundUri, audioAttributes)
        }

        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }
}
