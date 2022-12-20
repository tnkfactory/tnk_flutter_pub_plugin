import Flutter
import UIKit

public class SwiftTnkFlutterPubPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tnk_flutter_pub", binaryMessenger: registrar.messenger())
    let instance = SwiftTnkFlutterPubPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
