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
            
            let jsonData:[String:String] = [
                "placementId":placementId,
                "event": "onLoad"
            ] as Dictionary
            
            let data = parsingJsonObj(_data:jsonData)
            print( data )
            
            channel?.invokeMethod("TnkPubAdListener", arguments: data)
            
        }
        public func onShow(_ adItem: TnkAdItem) {
            print("tnk onShow")
            
            let jsonData:[String:String] = [
                "placementId":placementId,
                "event": "onShow"
            ] as Dictionary
            
            let data = parsingJsonObj(_data:jsonData)
            print( data )
            
            channel?.invokeMethod("TnkPubAdListener", arguments: data)
            
        }

        public func onError(_ adItem: TnkAdItem, error: AdError) {
            print("tnk onError")

            let jsonData:[String:String] = [
                "placementId":placementId,
                "message": String(error.rawValue) + error.description(),
                "event": "onError",
                "code": String(error.rawValue)
            ] as Dictionary

            let data = parsingJsonObj(_data:jsonData)
            print( data )


            channel?.invokeMethod("TnkPubAdListener", arguments: data)
        }

        public func onVideoCompletion(_ adItem:TnkAdItem, verifyCode:Int) {
            print("onVideoCompletion")

            let jsonData:[String:String] = [
                "code": String(verifyCode),
                "placementId": placementId,
                "event": "onVideoCompletion"
            ] as Dictionary

            let data = parsingJsonObj(_data:jsonData)
            print( data )


//            if verifyCode >= 0 {
//                // 적립 진행
//            }
//            else {
//                // 적립 실패
//            }

            channel?.invokeMethod("TnkPubAdListener", arguments: data)
        }
        
        public func onClose(_ adItem:TnkAdItem, type:AdClose) {
            print("onClose")
            
//            if(type.rawValue == 2) {
//                print("close")
//                return
//            }
            
            let jsonData:[String:String] = [
                "placementId":placementId,
                "event": "onClose",
                "type": String(type.rawValue)
            ] as Dictionary

            let data = parsingJsonObj(_data:jsonData)
            print( data )
            
            channel?.invokeMethod("TnkPubAdListener", arguments: data)
        }


        private func parsingJsonObj(_data: [String:String]) -> String {

            var jsonObj:String = ""
            do {
                let jsonCreate = try JSONSerialization.data(withJSONObject: _data)
                jsonObj = String(data:jsonCreate, encoding: .utf8) ?? ""
            } catch {
                print(error.localizedDescription)
            }

            return jsonObj
        }
    }
    
    
    
    
}
