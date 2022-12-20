
# tnk flutter plugin 설치 안내

## Installation

Open the terminal of your chosen IDE and run the following:

프로젝트의 IDE루트 경로에서 터미널을 열고 다음과 같이 실행하여 플러그인을 설치합니다.

```
flutter pub add tnk_flutter_pub
```


# 광고 출력

## 전면광고 출력 

아래와 같이 사용하여 테스트용 전면광고 출력이 가능합니다.

```dart
import 'package:tnk_flutter_ssp/tnk_flutter_ssp.dart';

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


# 앱 등록 및 광고 등록

테스트 광고 출력에 성공하셨다면 다음과 같은 단계를 따릅니다.

## 1. 홈페이지 가입 및 앱 등록
[티엔케이팩토리 홈페이지](https://tnkfactory.com/)로 이동 후 회원가입을 진행하고 앱을 등록합니다.

**이 과정은 영업팀의 안내를 받아 진행 하시는 것을 권장합니다.**


앱 등록 후 pub id를 발급받아 info.plist 파일에 tnk_pub_id 항목으로 추가하셔야합니다.

아래의 샘플을 참고하시어 실제 ID 를 등록하세요.

![tnk_pub_id](./img/tnk_pub_id.png)

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

