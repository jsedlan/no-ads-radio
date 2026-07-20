package com.sedlan.noadsradio

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.content.Context
import java.io.File
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        deleteOversizedLegacyPreferences()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.sedlan.noadsradio/android_settings"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openAppBatterySettings" -> result.success(openAppBatterySettings())
                "isIgnoringBatteryOptimizations" -> result.success(isIgnoringBatteryOptimizations())
                else -> result.notImplemented()
            }
        }
    }

    private fun openAppBatterySettings(): Boolean {
        if (!isIgnoringBatteryOptimizations()) {
            val requestIntent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            try {
                startActivity(requestIntent)
                return true
            } catch (_: Exception) {
                // Fall through to the broader settings screens below.
            }
        }

        val appSettingsIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        return try {
            startActivity(appSettingsIntent)
            true
        } catch (_: Exception) {
            val fallbackIntent = Intent(Settings.ACTION_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            try {
                startActivity(fallbackIntent)
                true
            } catch (_: Exception) {
                false
            }
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(packageName)
    }

    private fun deleteOversizedLegacyPreferences() {
        val maxReasonablePreferencesBytes = 8L * 1024L * 1024L
        val sharedPrefsDirectory = File(applicationInfo.dataDir, "shared_prefs")
        val preferenceFiles = sharedPrefsDirectory.listFiles() ?: return

        preferenceFiles
            .filter { file ->
                file.isFile &&
                    file.extension == "xml" &&
                    file.length() > maxReasonablePreferencesBytes
            }
            .forEach { file ->
                try {
                    file.delete()
                    File("${file.absolutePath}.bak").delete()
                } catch (_: Exception) {
                    // Continue startup; Dart has a fallback cleanup too.
                }
            }
    }
}
