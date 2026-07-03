import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';
import 'package:tnk_flutter_pub/tnk_banner_ad_view.dart';
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

  // 배너 광고 placement id (Tnk 콘솔에서 발급받은 값으로 교체)
  static const String _bannerPlacementId = "home_banner";
  static const String _homeBanner100 = "home_banner_100";

  // 배너 표시 여부 (버튼을 눌러야 노출). 배너 2개를 각각 제어한다.
  bool _showBanner1 = false;
  bool _showBanner2 = false;

  // 배너 재요청 카운터: 값이 바뀌면 위젯 key 가 바뀌어 PlatformView 가 재생성되고
  // 네이티브 배너가 새로 load 된다. (버튼을 다시 누를 때마다 새 광고 요청)
  int _bannerReloadCount1 = 0;
  int _bannerReloadCount2 = 0;

  @override
  void initState() {
    MethodChannel channel = const MethodChannel('tnk_flutter_pub');
    channel.setMethodCallHandler(tnkInvokedMethods);
    super.initState();
  }

  Future<dynamic> tnkInvokedMethods(MethodCall methodCall) async {
    TnkFlutterPubEventHandler.checkEvent(methodCall);
  }

  Future<void> showBanner(int slot) async {
    // 전면광고처럼 버튼을 눌렀을 때 배너를 노출한다.
    // 리스너를 등록(placementId 로 라우팅)하고 TnkBannerAdView 를 화면에 올리면
    // 위젯 생성 시점에 네이티브 배너가 load 된다.
    // 배너 2개가 같은 placementId 를 쓰므로 리스너는 한 번만 등록해도 된다.
    TnkFlutterPubEventHandler.addListener(_bannerPlacementId, ITnkAdListener(
      onLoad: () => print("banner onLoad"),
      onShow: () => print("banner onShow"),
      onClick: () => print("banner onClick"),
      onClose: (String type) {},
      onVideoCompletion: (String code) {},
      onError: (String code, String message) =>
          print("banner onError $code $message"),
    ));

    setState(() {
      // 클릭할 때마다 해당 슬롯의 배너를 새로 요청 (key 변경 -> PlatformView 재생성)
      if (slot == 1) {
        _showBanner1 = true;
        _bannerReloadCount1++;
      } else {
        _showBanner2 = true;
        _bannerReloadCount2++;
      }
    });
  }

  Future<void> showInterstitial() async {
    // 전면광고를 출력합니다.
    TnkFlutterPubEventHandler.showInterstitial( "banner", ITnkAdListener(
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) 버튼 영역: 광고를 노출시키는 액션 버튼들
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'result: $_tnkResult',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showInterstitial();
                          },
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black),
                          child: const Text('show interstitial'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showBanner(1);
                          },
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black),
                          child: const Text('show banner 1'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showBanner(2);
                          },
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black),
                          child: const Text('show banner 2'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2) 디바이더: 버튼 영역과 광고 출력 영역을 구분
            const Divider(height: 1, thickness: 1),

            // 3) 광고 출력 영역: 배너/전면 등 광고가 표시되는 공간
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.all(2.0),
                child: (!_showBanner1 && !_showBanner2)
                    ? const Text(
                        '광고 영역\n버튼을 누르면 여기에 광고가 표시됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black38),
                      )
                    // 배너 광고: 버튼을 누르면 각 지면의 "소재 비율"에 맞춰 영역이 잡히고
                    // 그 안에 PlatformView 로 노출된다. 소재 비율(aspectRatio = 가로/세로)만
                    // 지정하면 폭에 맞는 높이로 영역이 계산되고, 네이티브 SDK 가 그 크기에 맞게
                    // 소재를 채운다. (iOS 가이드의 height = 폭 * 200/640 방식과 동일)
                    // 배너 2개는 key 가 달라 각각 재생성/load 된다.
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_showBanner1)
                            // 지면 1: 640 x 200 소재
                            TnkBannerAdView(
                              key: ValueKey('banner1_$_bannerReloadCount1'),
                              placementId: _bannerPlacementId,
                              width: MediaQuery.of(context).size.width,
                              aspectRatio: 640 / 200,
                            ),
                          if (_showBanner1 && _showBanner2)
                            const SizedBox(height: 8),
                          if (_showBanner2)
                            // 지면 2: 640 x 100 소재
                            TnkBannerAdView(
                              key: ValueKey('banner2_$_bannerReloadCount2'),
                              placementId: _homeBanner100,
                              width: MediaQuery.of(context).size.width,
                              aspectRatio: 640 / 100,
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
