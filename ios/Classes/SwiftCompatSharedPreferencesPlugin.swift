import Flutter
import UIKit

public class SwiftCompatSharedPreferencesPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "compat_shared_preferences", binaryMessenger: registrar.messenger())
    let instance = SwiftCompatSharedPreferencesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
