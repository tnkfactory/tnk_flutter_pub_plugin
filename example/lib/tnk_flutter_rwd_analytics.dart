import 'dart:convert';

class TnkRewardVideoListener {
  // 이벤트명              // 파라미터(item_id, item_name)
  static const String TNK_PUB_ADLISTENER = "TnkPubAdListener";

  // 리워드 동영상 완료
  static const String PARAM_PLACEMENT_ID = "placementId"; // 광고 아이디
  static const String PARAM_ON_VIDEO_COMPLETION = "onVideoCompletion"; // success, fail

  // video completion 확인 코드
  static const String VIDEO_VERIFY_SUCCESS_S2S = "1"; // 매체 서버를 통해서 검증됨
  static const String VIDEO_VERIFY_SUCCESS_SELF = "0"; // 매체 서버 URL이 설정되지 않아 Tnk 자체 검증
  static const String VIDEO_VERIFY_FAILED_S2S = "-1"; // 매체 서버를 통해서 지급불가 판단됨
  static const String VIDEO_VERIFY_FAILED_TIMEOUT = "-2"; // 매체 서버 호출시 타임아웃 발생
  static const String VIDEO_VERIFY_FAILED_NO_DATA = "-3"; // 광고 송출 및 노출 이력 데이터가 없음
  static const String VIDEO_VERIFY_FAILED_TEST_VIDEO = "-4"; // 테스트 동영상 광고임
  static const String VIDEO_VERIFY_FAILED_ERROR = "-9"; // 그외 시스템 에러가 발생

  static const String SUCCESS = "success"; // 그외 시스템 에러가 발생
  static const String PASS = "PASS"; // 해당 placementid의 이벤트가 아님

  static String onEvent(dynamic event, String placementId) {
    Map<String, dynamic> jsonObject = jsonDecode(event);
    if (jsonObject[placementId] == placementId) {
      return PASS;
    }
    if (jsonObject["onError"] != null) {
      return jsonObject["onError"];
    } else if (jsonObject["onVideoCompletion"] != null) {
      switch (jsonObject["onVideoCompletion"]) {
        case VIDEO_VERIFY_FAILED_S2S:
          return SUCCESS;
        case VIDEO_VERIFY_SUCCESS_SELF:
          return SUCCESS;
        case VIDEO_VERIFY_FAILED_TIMEOUT:
          return "매체 서버 호출시 타임아웃 발생";
        case VIDEO_VERIFY_FAILED_NO_DATA:
          return "광고 송출 및 노출 이력 데이터가 없음";
        case VIDEO_VERIFY_FAILED_TEST_VIDEO:
          return "테스트 동영상 광고임";
        case VIDEO_VERIFY_FAILED_ERROR:
          return "그외 시스템 에러가 발생";
      }
    }
    return "pass";
  }
}
