
import 'tnk_flutter_pub_platform_interface.dart';

class TnkFlutterPub {
  Future<String?> getPlatformVersion() {
    return TnkFlutterPubPlatform.instance.getPlatformVersion();
  }
  Future<String?> showInterstitial(placementId) {
    return TnkFlutterPubPlatform.instance.showInterstitial(placementId);
  }
}
