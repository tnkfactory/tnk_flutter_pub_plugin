import Flutter
import UIKit
import TnkPubSdk

public class SwiftTnkFlutterPubPlugin: NSObject, FlutterPlugin, TnkPubSdk.TnkAdListener {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tnk_flutter_pub", binaryMessenger: registrar.messenger())
    let instance = SwiftTnkFlutterPubPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let viewController = UIApplication.shared.keyWindow?.rootViewController
    switch call.method {
        case "showInterstitial":
            let adItem = TnkInterstitialAdItem(viewController: viewController!, placementId: "TEST_INTERSTITIAL_V")
                adItem.setListener(self)
                adItem.load()
                result("iOS success")
                break;
        case "platformVersion":
                result("iOS " + UIDevice.current.systemVersion)
                break;
        case "exitInterstitial":
            let adItem = TnkInterstitialAdItem(viewController: viewController!, placementId: "TEST_INTERSTITIAL_V")
                adItem.setListener(self)
                adItem.load()
                result("iOS success")
            break;
        default:
            result("iOS method : " + call.method  )
            break;
        }
  }
    
    public func onLoad(_ adItem: TnkAdItem) {
        adItem.show()
        print("tnk onLoad")
    }
    public func onShow(_ adItem: TnkAdItem) {
        print("tnk onShow")
    }
    
    public func onError(_ adItem: TnkAdItem, error: AdError) {
        print("tnk onError \(error.rawValue)")
    }
}
