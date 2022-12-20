import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tnk_flutter_pub_platform_interface.dart';

/// An implementation of [TnkFlutterPubPlatform] that uses method channels.
class MethodChannelTnkFlutterPub extends TnkFlutterPubPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tnk_flutter_pub');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  @override
  Future<String?> showInterstitial(placementId) async {
    final version = await methodChannel.invokeMethod<String>('showInterstitial', placementId);
    return version;
  }
}
