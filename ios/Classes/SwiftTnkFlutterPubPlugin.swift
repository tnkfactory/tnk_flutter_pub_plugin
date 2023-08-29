import Flutter
import UIKit
import TnkPubSdk
import AppTrackingTransparency
import AdSupport

public class SwiftTnkFlutterPubPlugin: NSObject, FlutterPlugin {
    
    static var channel:FlutterMethodChannel? = nil
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "tnk_flutter_pub", binaryMessenger: registrar.messenger())
        let instance = SwiftTnkFlutterPubPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }
    
    var listener:FlutterListener? = nil
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        switch call.method {
        case "showInterstitial":
            TnkAdConfiguration.setCOPPA(false)
            requestPermission()
            guard let placementId = call.arguments as? String else {
                result(FlutterError(code: call.method, message: "Missing placementid", details: nil))
                return
            }
            
            listener = FlutterListener(placementId: placementId, viewController: viewController!)
            listener?.loadItem()
            
            
            let adItem = TnkInterstitialAdItem(viewController: viewController!, placementId: placementId)
            adItem.load()
            
            break;
        case "platformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break;
        case "exitInterstitial":
            result("iOS not support exitInterstitial")
            break;
        default:
            result("iOS method : " + call.method  )
            break;
        }
    }
    public func requestPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    
                    // Now that we are authorized we can get the IDFA
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    class FlutterListener : TnkPubSdk.TnkAdListener {
        var placementId:String
        var viewController:UIViewController
        init(placementId: String, viewController:UIViewController) {
            self.placementId = placementId
            self.viewController = viewController
        }
        
        public func loadItem(){
            let adItem = TnkInterstitialAdItem(viewController: viewController, placementId: placementId)
            //let listener = FlutterListener(placementId: placementId)
            adItem.setListener(self)
            adItem.load()
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
            let des = error.description()
            
            let jsonData:[String:Any] = [
                "placementId":placementId,
                "onError": String(error.rawValue) + error.description()
            ] as Dictionary
            
            
            
            let result = parsingJsonObj(_data:jsonData)
            print( result )
            
            
            channel?.invokeMethod("TnkAdListener", arguments: result)
            
        }
        
        public func onVideoCompletion(_ adItem:TnkAdItem, verifyCode:Int) {
            print("onVideoCompletion")
            
            let jsonData:[String:Any] = [
                "placementId":placementId,
                "onVideoCompletion": String(verifyCode)
            ] as Dictionary
            
            let result = parsingJsonObj(_data:jsonData)
            print( result )
            
            channel?.invokeMethod("TnkAdListener", arguments: result)
            if verifyCode >= 0 {
                // 적립 진행
                
                
            }
            else {
                // 적립 실패
                
                
            }
        }
        
        
        private func parsingJsonObj(_data: [String:Any]) -> String {
            
            var jsonObj:String = ""
            do {
                let jsonCreate = try JSONSerialization.data(withJSONObject: _data, options:.prettyPrinted)
                jsonObj = String(data:jsonCreate, encoding: .utf8) ?? ""
            } catch {
                print(error.localizedDescription)
            }
            
            return jsonObj
            
        }
        
        
    }
    
    
    
    
}
