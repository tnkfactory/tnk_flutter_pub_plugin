
# tnk flutter plugin 설치 안내

## Installation

Open the terminal of your chosen IDE and run the following:

프로젝트의 IDE루트 경로에서 터미널을 열고 다음과 같이 실행하여 플러그인을 설치합니다.

```
flutter pub add tnk_flutter_pub
```

## iOS프로젝트 설정 

##### info.plist 파일에 "Privacy - Tracking Usage Description" 을 추가합니다. 추가되는 문구는 앱 추적 동의 팝업 창에 노출됩니다.

###### 작성예시

**사용자에게 적합한 광고를 제공하고 참여여부를 확인하기 위하여 광고ID를 수집합니다. 광고ID는 오퍼월 서비스를 제공하기 위해서 필수적인 항목으로 추적허용을 해주셔야 사용이 가능합니다.**

![Guide_08](https://github.com/tnkfactory/ios-sdk-rwd/blob/master/img/Guide_08.png)

# 광고 출력

## 전면광고 출력 

아래와 같이 사용하여 테스트용 전면광고 출력이 가능합니다.

```dart
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';

class _MyAppState extends State<MyApp> {
  String _tnkResult = 'Unknown';
  // Tnk pub plugin
  final _tnkFlutterPubPlugin = TnkFlutterPub();

  @override
  void initState() {
    super.initState();
  }

  Future<void> showInterstitial() async {
    String tnkResult;
    try {
      // 전면광고를 출력합니다.
      tnkResult = await _tnkFlutterPubPlugin.showInterstitial("TEST_INTERSTITIAL_V") ?? "onFail";
    } on PlatformException catch(e){
      tnkResult = e.message ?? "onFail";
    }

    if (!mounted) return;

    setState(() {
      _tnkResult = tnkResult;
    });
  }
  
  // ...
  // ...
}

```

# 동영상광고 콜백

## 동영상 콜백 이벤트 발생 시점에따라 분기처리가 가능합니다.

```
1. onLoad() // 광고로드 후 광고가 도착하면 호출됨
2. onShow() // 광고 화면이 화면이 나타나는 시점에 호출된다.
3. onCLose() // 화면 닫힐 때 호출됨
4. onVideoCompletion() // 동영상이 포함되어 있는 경우 동영상을 끝까지 시청하는 시점에 호출된다. 
5. onError() // 광고 처리중 오류 발생시 호출됨
```

```dart
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';
import 'package:tnk_flutter_pub_example/tnk_flutter_rwd_analytics.dart';

Future<void> showInterstitial() async {
    // 전면광고를 출력합니다.
    TnkFlutterPubEventHandler.shoInterstitial( "pubtest", ITnkAdListener(
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

```


# 앱 등록 및 광고 등록

테스트 광고 출력에 성공하셨다면 다음과 같은 단계를 따릅니다.

## 1. 홈페이지 가입 및 앱 등록
[티엔케이팩토리 홈페이지](https://tnkfactory.com/)로 이동 후 회원가입을 진행하고 앱을 등록합니다.

**이 과정은 영업팀의 안내를 받아 진행 하시는 것을 권장합니다.**


앱 등록 후 pub id를 발급받아 info.plist 파일에 tnk_pub_id 항목으로 추가하셔야합니다.

아래의 샘플을 참고하시어 실제 ID 를 등록하세요.

![tnk_pub_id](https://github.com/tnkfactory/ios-pub-sdk/blob/main/img/tnk_pub_id.png)

실제 ID 를 등록하면 위 Test Flight 코드에서는 더 이상 광고가 나타나지 않습니다. Tnk Publish Site 에서 광고 유형에 맞추어 Placement 를 등록하시고 등록한 Placement의 이름을 사용하셔야 실제 광고가 표시됩니다.


## 2. 테스트 광고 등록

테스트 광고 등록 후 placement id를 사용하여 광고를 호출합니다.

```dart

try {
  // 전면광고를 출력합니다.
  tnkResult = await _tnkFlutterPubPlugin.showInterstitial("관리자 페이지에서 등록한 placement id") ?? "onFail";
} on PlatformException catch(e){
  tnkResult = e.message ?? "onFail";
}
```

모든 단계를 마친 후 등록한 placement id를 사용하여 광고가 출력되었다면 성공입니다.

