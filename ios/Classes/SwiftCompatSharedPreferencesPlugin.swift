import Flutter
import UIKit

/// This code is currently not used because of uncentrain compatibility with legacy implementation.
public class SwiftCompatSharedPreferencesPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "compat_shared_preferences", binaryMessenger: registrar.messenger())
        let instance = SwiftCompatSharedPreferencesPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private var success = NSNumber(booleanLiteral: true)
    
//    Dart -> Swift conversion table
//    https://docs.flutter.dev/development/platform-integration/platform-channels?tab=type-mappings-swift-tab
//    +----------------------------+-----------------------------------------+
//    | Dart                       | Swift                                   |
//    +----------------------------+-----------------------------------------+
//    | null                       | nil                                     |
//    | bool                       | NSNumber(value: Bool)                   |
//    | int                        | NSNumber(value: Int32)                  |
//    | int, if 32 bits not enough | NSNumber(value: Int)                    |
//    | double                     | NSNumber(value: Double)                 |
//    | String                     | String                                  |
//    | Uint8List                  | FlutterStandardTypedData(bytes: Data)   |
//    | Int32List                  | FlutterStandardTypedData(int32: Data)   |
//    | Int64List                  | FlutterStandardTypedData(int64: Data)   |
//    | Float32List                | FlutterStandardTypedData(float32: Data) |
//    | Float64List                | FlutterStandardTypedData(float64: Data) |
//    | List                       | Array                                   |
//    | Map                        | Dictionary                              |
//    +----------------------------+-----------------------------------------+
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let arguments = call.arguments as? [String: Any]
        let userDefaults = UserDefaults.standard
        switch method {
        case "getAll":
            result(getAllPreferences())
        case "setBool":
            let key = arguments!["key"] as! String
            let value = arguments!["value"] as! NSNumber
            userDefaults.set(value.boolValue, forKey: key)
            result(success)
        case "setDouble":
            let key = arguments!["key"] as! String
            let value = arguments!["value"] as! NSNumber
            userDefaults.set(value.doubleValue, forKey: key)
            result(success)
        case "setInt", "setString", "setStringList":
            let key = arguments!["key"] as! String
            let value = arguments!["value"]
            userDefaults.setValue(value, forKey: key)
            result(success)
        case "commit":
            // depricated, it was made to "synchronize" user defaults
            result(success)
        case "remove":
            let key = arguments!["key"] as! String
            userDefaults.removeObject(forKey: key)
            result(success)
        case "clear":
            let all = getAllPreferences()
            all.keys.forEach { key in
                userDefaults.removeObject(forKey: key)
            }
            result(success)
        default:
            result(FlutterMethodNotImplemented)
        }
        //    result("iOS " + UIDevice.current.systemVersion)
    }
    
    private func getAllPreferences() -> [String: Any] {
        guard let appDomain = Bundle.main.bundleIdentifier else {
            assertionFailure("This plugin assumes it is running with Bundle ID set")
            return [:]
        }
        let preferences = UserDefaults.standard.persistentDomain(forName: appDomain)
        return preferences ?? [:]
        
    }
}
