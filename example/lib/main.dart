import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';
import 'package:tnk_flutter_pub_example/tnk_flutter_rwd_analytics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tnkResult = 'Unknown';

  // Tnk pub plugin
  final _tnkFlutterPubPlugin = TnkFlutterPub();

  @override
  void initState() {
    MethodChannel channel = const MethodChannel('tnk_flutter_pub');
    channel.setMethodCallHandler(tnkInvokedMethods);
    super.initState();
  }

  Future<dynamic> tnkInvokedMethods(MethodCall methodCall) async {
    TnkFlutterPubEventHandler.checkEvent(methodCall);
  }

  Future<void> showInterstitial() async {
    // 전면광고를 출력합니다.
    TnkFlutterPubEventHandler.shoInterstitial( "puttest", ITnkAdListener(
          onLoad: () {
            print("onLoad");

          },
          onShow: () {
            print("onShow");

          },
          onClose: (String type) {

            print("onClose $type");
            switch(type) {
              case TnkRewardVideoListener.CLOSE:
                print( "닫기버튼 클릭");
                break;
              case TnkRewardVideoListener.AUTO_CLOSE:
                print( "자동 닫기");
                break;
              case TnkRewardVideoListener.EXIT:
                print( "종료 버튼 클릭");
                break;
            }

          },
          onVideoCompletion: (String code) {
            print("onVideoCompletion $code");
            switch (code) {
              case TnkRewardVideoListener.VIDEO_VERIFY_SUCCESS_S2S:
                print("성공");
                break;
              case TnkRewardVideoListener.VIDEO_VERIFY_SUCCESS_SELF:
                print("성공");
                break;
              case TnkRewardVideoListener.VIDEO_VERIFY_FAILED_TIMEOUT:
                print("매체 서버를 통해서 지급불가 판단됨");
                break;
              case TnkRewardVideoListener.VIDEO_VERIFY_FAILED_NO_DATA:
                print("광고 송출 및 노출 이력 데이터가 없음");
                break;
              case TnkRewardVideoListener.VIDEO_VERIFY_FAILED_TEST_VIDEO:
                print("테스트 동영상 광고임");
                break;
              case TnkRewardVideoListener.VIDEO_VERIFY_FAILED_ERROR:
                print("그외 시스템 에러가 발생");
                break;
              default:
                print("그외 시스템 에러가 발생");
                break;
            }

          },


          onError: (String code, String message) {
            print("onError $code $message");
            switch (code) {
              case TnkRewardVideoListener.NoError:
                print("성공");
                break;
              case TnkRewardVideoListener.NoAd:
                print("광고 없음");
                break;
              case TnkRewardVideoListener.NoImage:
                print("이미지 없음");
                break;
              case TnkRewardVideoListener.Timeout:
                print("타임아웃");
                break;
              case TnkRewardVideoListener.Cancel:
                print("사용자 취소");
                break;
              case TnkRewardVideoListener.ShowBeforeLoad:
                print("load() 호출 후 show() 호출 전에 close() 호출");
                break;
              case TnkRewardVideoListener.NoAdFrame:
                print("광고 뷰가 없음");
                break;
              case TnkRewardVideoListener.DupLoad:
                print("이미 load() 호출된 상태");
                break;
              case TnkRewardVideoListener.DupShow:
                print("이미 show() 호출된 상태");
                break;
              case TnkRewardVideoListener.NoPlacementId:
                print("placementId가 없음");
                break;
              case TnkRewardVideoListener.NoScreenOrientation:
                print("화면 방향이 없음");
                break;
              case TnkRewardVideoListener.NoTestDevice:
                print("테스트 디바이스가 아님");
                break;
              case TnkRewardVideoListener.SystemFailure:
                print("시스템 오류");
                break;
              default:
            }

          },
        ));

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('tnk pub plugin test app'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('result \n\n$_tnkResult\n'),
            OutlinedButton(
              onPressed: () {
                showInterstitial();
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('show interstitial'),
            ),
          ],
        )),
      ),
    );
  }
}
