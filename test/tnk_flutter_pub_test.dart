import 'package:flutter_test/flutter_test.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub_platform_interface.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTnkFlutterPubPlatform
    with MockPlatformInterfaceMixin
    implements TnkFlutterPubPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TnkFlutterPubPlatform initialPlatform = TnkFlutterPubPlatform.instance;

  test('$MethodChannelTnkFlutterPub is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTnkFlutterPub>());
  });

  test('getPlatformVersion', () async {
    TnkFlutterPub tnkFlutterPubPlugin = TnkFlutterPub();
    MockTnkFlutterPubPlatform fakePlatform = MockTnkFlutterPubPlatform();
    TnkFlutterPubPlatform.instance = fakePlatform;

    expect(await tnkFlutterPubPlugin.getPlatformVersion(), '42');
  });
}
