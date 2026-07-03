import Flutter
import UIKit

/// `tnk_flutter_pub/banner_ad` PlatformView 를 생성하는 팩토리.
/// Flutter 의 creationParams 에서 placementId 를 받아 [TnkBannerAdPlatformView] 를 만든다.
class TnkBannerAdViewFactory: NSObject, FlutterPlatformViewFactory {

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        var placementId = ""
        if let dict = args as? [String: Any], let pid = dict["placementId"] as? String {
            placementId = pid
        }
        return TnkBannerAdPlatformView(
            frame: frame,
            placementId: placementId
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
