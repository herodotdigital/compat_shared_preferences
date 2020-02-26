package com.goldapp.compat_shared_preferences

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

/** CompatSharedPreferencesPlugin */
public class CompatSharedPreferencesPlugin() : FlutterPlugin {
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        setupChannel(flutterPluginBinding.binaryMessenger, flutterPluginBinding.applicationContext)
    }


    companion object {
        private const val CHANNEL_NAME = "compat_shared_preferences"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin: CompatSharedPreferencesPlugin = CompatSharedPreferencesPlugin()
            plugin.setupChannel(registrar.messenger(), registrar.context())
        }
    }

    private var channel: MethodChannel? = null


    private fun setupChannel(messenger: BinaryMessenger, context: Context) {
        channel = MethodChannel(messenger, CHANNEL_NAME).apply {
            val handler = CompatSharedPreferencesMethodHandler(context)
            this.setMethodCallHandler(handler)
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPluginBinding) = teardownChannel()


    private fun teardownChannel() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

}
