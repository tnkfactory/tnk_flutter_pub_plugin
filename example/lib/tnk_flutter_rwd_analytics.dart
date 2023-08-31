import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';

class TnkRewardVideoListener {
  static const String METHOD_NAME = "TnkPubAdListener";

  static const String EVENT_ON_LOAD = "onLoad";
  static const String EVENT_ON_SHOW = "onShow";
  static const String EVENT_ON_CLOSE = "onClose";
  static const String EVENT_ON_VIDEO_COMPLETION = "onVideoCompletion";
  static const String EVENT_ON_ERROR = "onError";

  // 리워드 동영상 완료
  static const String PARAM_PLACEMENT_ID = "placementId"; // 광고 아이디

  // video completion 확인 코드
  static const String VIDEO_VERIFY_SUCCESS_S2S = "1"; // 매체 서버를 통해서 검증됨
  static const String VIDEO_VERIFY_SUCCESS_SELF = "0"; // 매체 서버 URL이 설정되지 않아 Tnk 자체 검증
  static const String VIDEO_VERIFY_FAILED_S2S = "-1"; // 매체 서버를 통해서 지급불가 판단됨
  static const String VIDEO_VERIFY_FAILED_TIMEOUT = "-2"; // 매체 서버 호출시 타임아웃 발생
  static const String VIDEO_VERIFY_FAILED_NO_DATA = "-3"; // 광고 송출 및 노출 이력 데이터가 없음
  static const String VIDEO_VERIFY_FAILED_TEST_VIDEO = "-4"; // 테스트 동영상 광고임
  static const String VIDEO_VERIFY_FAILED_ERROR = "-9"; // 그외 시스템 에러가 발생
}

/// 이벤트 리스너 인터페이스
/// onLoad(code, message)
/// onShow(code, message)
/// onClose(code, message)
/// onVideoCompletion(code, message)
/// onError(code, message)
class ITnkAdListener {
  // /**
  //  * 광고 클릭시 호출됨
  //  * 광고 화면은 닫히지 않음
  //  * @param adItem 이벤트 대상이되는 AdItem 객체
  //  */
  // optional func onClick(_ adItem:TnkAdItem)

  /// 광고 load() 후 광고가 도착하면 호출됨
  /// @param adItem 이벤트 대상이되는 AdItem 객체
  Function() onLoad = () {};

  /// 광고 화면이 화면이 나타나는 시점에 호출된다.
  /// @param adItem 이벤트 대상이되는 AdItem 객체
  Function() onShow = () {};

  /// 화면 닫힐 때 호출됨
  /// @param adItem 이벤트 대상이되는 AdItem 객체
  /// @param type 0:simple close, 1: auto close, 2:exit
  Function(String type) onClose = (String type) {};

  /// 동영상이 포함되어 있는 경우 동영상을 끝까지 시청하는 시점에 호출된다.
  /// @param adItem 이벤트 대상이되는 AdItem 객체
  /// @param verifyCode 동영상 시청 완료 콜백 결과.
  Function(String code) onVideoCompletion = (String code) {};

  /// 광고 처리중 오류 발생시 호출됨
  /// @param adItem 이벤트 대상이되는 AdItem 객체
  /// @param error AdError
  Function(String code, String message) onError = (String code, String message) {};

  ITnkAdListener({
    required this.onLoad,
    required this.onShow,
    required this.onClose,
    required this.onVideoCompletion,
    required this.onError,
  });
}

class TnkPubAdItem {
  String placementId;
  ITnkAdListener listener;

  TnkPubAdItem(this.placementId, this.listener);

  void checkEvent(MethodCall methodCall) {
    Map<String, dynamic> jsonObject = jsonDecode(methodCall.arguments);
    switch (jsonObject["event"]) {
      case TnkRewardVideoListener.EVENT_ON_LOAD:
        listener.onLoad();
        break;
      case TnkRewardVideoListener.EVENT_ON_SHOW:
        listener.onShow();
        break;
      case TnkRewardVideoListener.EVENT_ON_CLOSE:
        listener.onClose(jsonObject["type"]);
        break;
      case TnkRewardVideoListener.EVENT_ON_VIDEO_COMPLETION:
        listener.onVideoCompletion(jsonObject["code"]);
        break;
      case TnkRewardVideoListener.EVENT_ON_ERROR:
        listener.onError(jsonObject["code"], jsonObject["message"]);
        break;
    }
  }
}

class TnkFlutterPubEventHandler {

  static final _tnkFlutterPubPlugin = TnkFlutterPub();

  static final Map<String, TnkPubAdItem> _adMap = Map();

  static void shoInterstitial(String placementId, ITnkAdListener listener) {
    _tnkFlutterPubPlugin.showInterstitial(placementId);
    addListener(placementId, listener);
  }
  static void addListener(String placementId, ITnkAdListener listener) {
    _adMap[placementId] = TnkPubAdItem(placementId, listener);
  }

  static void removeAdItem(String placementId) {
    _adMap.remove(placementId);
  }

  static void checkEvent(MethodCall methodCall) {
    if (methodCall.method == TnkRewardVideoListener.METHOD_NAME) {
      Map<String, dynamic> jsonObject = jsonDecode(methodCall.arguments);

      String placementId = jsonObject[TnkRewardVideoListener.PARAM_PLACEMENT_ID];

      _adMap[placementId]?.checkEvent(methodCall);
    }
  }
}
