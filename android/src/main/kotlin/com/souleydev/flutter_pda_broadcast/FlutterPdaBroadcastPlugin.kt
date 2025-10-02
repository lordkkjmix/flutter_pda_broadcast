package com.souleydev.flutter_pda_broadcast

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterPdaBroadcastPlugin */
class FlutterPdaBroadcastPlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var scanReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null
    
    // Configuration par défaut
    private var broadcastAction = "com.kte.scan.result"
    private var barcodeExtra = "code"
    private var typeExtra = "type"
    private var originalExtra = "code_sro"
    private var debugLogs = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        
        methodChannel = MethodChannel(binding.binaryMessenger, "flutter_pda_broadcast")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "flutter_pda_broadcast_events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                registerScanReceiver()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                unregisterScanReceiver()
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "configure" -> {
                val config = call.arguments as? Map<String, Any>
                configure(config)
                result.success(true)
            }
            "getPdaInfo" -> {
                result.success(getPdaInfo())
            }
            "enableScanner" -> {
                enableScanner(true)
                result.success(true)
            }
            "disableScanner" -> {
                enableScanner(false)
                result.success(true)
            }
            "startScan" -> {
                startScan()
                result.success(true)
            }
            "stopScan" -> {
                stopScan()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun configure(config: Map<String, Any>?) {
        config?.let {
            broadcastAction = it["broadcastAction"] as? String ?: broadcastAction
            barcodeExtra = it["barcodeExtra"] as? String ?: barcodeExtra
            typeExtra = it["typeExtra"] as? String ?: typeExtra
            originalExtra = it["originalExtra"] as? String ?: originalExtra
            debugLogs = it["enableDebugLogs"] as? Boolean ?: debugLogs
            
            log("Configuration mise à jour")
            log("Action: $broadcastAction")
            log("Extras: $barcodeExtra, $typeExtra, $originalExtra")
        }
    }

    private fun registerScanReceiver() {
        scanReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                intent?.let {
                    if (it.action == broadcastAction) {
                        val barcode = it.getStringExtra(barcodeExtra) ?: ""
                        val type = it.getStringExtra(typeExtra) ?: ""
                        val original = it.getStringExtra(originalExtra) ?: ""

                        log("━━━━━━━━━━━━━━━━━━━━━━━━")
                        log("📦 SCAN REÇU")
                        log("Code: $barcode")
                        log("Type: $type")
                        if (original.isNotEmpty() && original != barcode) {
                            log("Original: $original")
                        }
                        log("━━━━━━━━━━━━━━━━━━━━━━━━")

                        if (barcode.isNotEmpty()) {
                            val result = hashMapOf(
                                "barcode" to barcode,
                                "type" to type,
                                "original" to original,
                                "timestamp" to System.currentTimeMillis()
                            )
                            eventSink?.success(result)
                        } else {
                            logError("⚠️ Code vide reçu!")
                        }
                    }
                }
            }
        }

        val filter = IntentFilter(broadcastAction)

        try {
            context?.let { ctx ->
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    ctx.registerReceiver(scanReceiver, filter, Context.RECEIVER_EXPORTED)
                } else {
                    ctx.registerReceiver(scanReceiver, filter)
                }
                log("✅ Scanner prêt")
            }
        } catch (e: Exception) {
            logError("❌ Erreur enregistrement: ${e.message}")
            eventSink?.error("RECEIVER_ERROR", e.message, null)
        }
    }

    private fun unregisterScanReceiver() {
        scanReceiver?.let {
            try {
                context?.unregisterReceiver(it)
                log("🔌 Scanner déconnecté")
            } catch (e: Exception) {
                logError("Erreur désenregistrement: ${e.message}")
            }
        }
        scanReceiver = null
    }

    private fun getPdaInfo(): Map<String, Any> {
        return mapOf(
            "manufacturer" to "KingTop",
            "model" to "KT-KP36",
            "broadcastAction" to broadcastAction,
            "status" to "ready"
        )
    }

    private fun enableScanner(enable: Boolean) {
        try {
            val action = if (enable) "ACTION_ENABLE_SCAN" else "ACTION_DISABLE_SCAN"
            context?.sendBroadcast(Intent(action))
            log("Scanner ${if (enable) "activé" else "désactivé"}")
        } catch (e: Exception) {
            logError("Erreur enableScanner: ${e.message}")
        }
    }

    private fun startScan() {
        try {
            context?.sendBroadcast(Intent("ACTION_START_SCAN"))
            log("▶️ Scan démarré")
        } catch (e: Exception) {
            logError("Erreur startScan: ${e.message}")
        }
    }

    private fun stopScan() {
        try {
            context?.sendBroadcast(Intent("ACTION_STOP_SCAN"))
            log("⏹️ Scan arrêté")
        } catch (e: Exception) {
            logError("Erreur stopScan: ${e.message}")
        }
    }

    private fun log(message: String) {
        if (debugLogs) {
            android.util.Log.d("FlutterPdaBroadcast", message)
        }
    }

    private fun logError(message: String) {
        android.util.Log.e("FlutterPdaBroadcast", message)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        unregisterScanReceiver()
        methodChannel.setMethodCallHandler(null)
        context = null
    }
}
