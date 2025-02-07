package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new dev.jerson.fast_rsa.FastRsaPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin fast_rsa, dev.jerson.fast_rsa.FastRsaPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.pauldemarco.flutter_blue.FlutterBluePlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin flutter_blue, com.pauldemarco.flutter_blue.FlutterBluePlugin", e);
    }
  }
}
