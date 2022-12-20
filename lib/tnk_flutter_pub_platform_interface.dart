import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tnk_flutter_pub_method_channel.dart';

abstract class TnkFlutterPubPlatform extends PlatformInterface {
  /// Constructs a TnkFlutterPubPlatform.
  TnkFlutterPubPlatform() : super(token: _token);

  static final Object _token = Object();

  static TnkFlutterPubPlatform _instance = MethodChannelTnkFlutterPub();

  /// The default instance of [TnkFlutterPubPlatform] to use.
  ///
  /// Defaults to [MethodChannelTnkFlutterPub].
  static TnkFlutterPubPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TnkFlutterPubPlatform] when
  /// they register themselves.
  static set instance(TnkFlutterPubPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<String?> showInterstitial(placementId) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
