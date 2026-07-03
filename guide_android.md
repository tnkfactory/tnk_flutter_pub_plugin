
# tnk flutter plugin 설치 안내 (Android)

## Installation

프로젝트의 IDE 루트 경로에서 터미널을 열고 다음과 같이 실행하여 플러그인을 설치합니다.

```
flutter pub add tnk_flutter_pub
```

## Android 프로젝트 설정

`android/app/build.gradle` 에서 다음을 확인/설정합니다. (전면광고 SDK 특성상 minSdk 21,
멀티덱스가 필요합니다.)

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        multiDexEnabled true
    }
}
```

앱 등록 후 발급받은 pub id 를 `AndroidManifest.xml` 의 `<application>` 하위에 추가합니다.
(테스트 단계에서는 아래 값 없이도 테스트 광고 출력이 가능합니다.)

```xml
<application ... >
    ...
    <meta-data android:name="tnk_pub_id" android:value="YOUR-INVENTORY-ID-HERE" />
    ...
</application>
```

---

# 기능 1. 이벤트 핸들러 초기화 (공통, 필수)

전면광고/배너광고의 콜백(onLoad/onShow/onClick/onClose/onError 등)은 네이티브에서
`tnk_flutter_pub` MethodChannel 의 `TnkPubAdListener` 로 전달됩니다. 앱 시작 시
한 번 채널 핸들러를 `TnkFlutterPubEventHandler` 에 연결해 두면, 이후 등록한
`placementId` 리스너로 이벤트가 라우팅됩니다.

```dart
import 'package:flutter/services.dart';
import 'package:tnk_flutter_pub_example/tnk_flutter_rwd_analytics.dart';

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 네이티브 -> Flutter 광고 이벤트 채널을 이벤트 핸들러에 연결
    const MethodChannel('tnk_flutter_pub')
        .setMethodCallHandler((call) async {
      TnkFlutterPubEventHandler.checkEvent(call);
    });
  }
}
```

> `TnkFlutterPubEventHandler.checkEvent` 는 이벤트의 `placementId` 를 읽어
> `addListener` / `showInterstitial` 로 등록된 해당 광고의 `ITnkAdListener` 로 콜백을 전달합니다.

---

# 기능 2. 전면광고 (Interstitial)

전면광고는 SDK 가 전체 화면으로 띄우는 광고입니다. `TnkFlutterPubEventHandler.showInterstitial`
에 `placementId` 와 리스너를 전달하면, 내부적으로 리스너 등록 + 광고 호출이 함께 처리됩니다.

```dart
import 'package:tnk_flutter_pub_example/tnk_flutter_rwd_analytics.dart';

Future<void> showInterstitial() async {
  TnkFlutterPubEventHandler.showInterstitial(
    "TEST_INTERSTITIAL_V", // 테스트 placement (실서비스는 콘솔에서 등록한 placement id)
    ITnkAdListener(
      onLoad: () => print("onLoad"),   // 광고 로드 완료
      onShow: () => print("onShow"),   // 광고 화면 노출
      onClose: (String type) {         // 광고 닫힘
        switch (type) {
          case TnkRewardVideoListener.CLOSE:      print("닫기 버튼 클릭"); break;
          case TnkRewardVideoListener.AUTO_CLOSE: print("자동 닫기"); break;
          case TnkRewardVideoListener.EXIT:       print("종료 버튼 클릭"); break;
        }
      },
      onVideoCompletion: (String code) { // 동영상 포함 시, 끝까지 시청 시점
        switch (code) {
          case TnkRewardVideoListener.VIDEO_VERIFY_SUCCESS_S2S:
          case TnkRewardVideoListener.VIDEO_VERIFY_SUCCESS_SELF:
            print("리워드 지급 성공");
            break;
          default:
            print("리워드 검증 실패/에러: $code");
        }
      },
      onError: (String code, String message) { // 오류 발생
        switch (code) {
          case TnkRewardVideoListener.NoAd:    print("광고 없음"); break;
          case TnkRewardVideoListener.Timeout: print("타임아웃"); break;
          default:                             print("onError $code $message");
        }
      },
    ),
  );
}
```

### 콜백 이벤트 발생 시점

```
1. onLoad()            // 광고 로드 후 광고가 도착하면 호출
2. onShow()            // 광고 화면이 나타나는 시점에 호출
3. onClose(type)       // 화면이 닫힐 때 호출 (type: 0 닫기 / 1 자동 / 2 종료)
4. onVideoCompletion() // 동영상 광고를 끝까지 시청한 시점에 호출
5. onError(code, msg)  // 광고 처리 중 오류 발생 시 호출
```

주요 코드 상수는 `TnkRewardVideoListener` 에 정의되어 있습니다. (에러코드 `NoAd = "-1"`,
close type `EXIT = "2"`, 동영상 검증 `VIDEO_VERIFY_SUCCESS_S2S = "1"` 등)

---

# 기능 3. 배너광고 (Banner)

배너광고는 화면 일부 영역에 인라인으로 노출되는 광고입니다. `TnkBannerAdView` 위젯을
화면에 배치하면, 위젯이 생성되는 시점에 네이티브 배너가 자동으로 `load` 됩니다.
광고 UI 는 SDK 가 직접 그립니다.

### 소재 비율(aspectRatio)로 영역 잡기

Tnk SDK 는 광고를 그릴 컨테이너를 **소재 비율에 맞는 크기**로 주면 그 크기에 맞게 소재를
그립니다. 그래서 `TnkBannerAdView` 는 소재 비율 `aspectRatio`(= 가로/세로)만 받으면
**폭에 맞는 높이(`폭 / aspectRatio`)로 영역을 자동 계산**합니다.

- 640×100 소재 → `aspectRatio: 640 / 100` (기본값)
- 640×200 소재 → `aspectRatio: 640 / 200`

폭은 부모 제약을 그대로 쓰거나(`Column(crossAxisAlignment: stretch)` 등) `width` 로 지정합니다.

```dart
import 'package:tnk_flutter_pub/tnk_banner_ad_view.dart';
import 'package:tnk_flutter_pub_example/tnk_flutter_rwd_analytics.dart';

// (선택) 배너 이벤트를 받으려면 placementId 로 리스너를 등록해 둔다.
TnkFlutterPubEventHandler.addListener(
  "home_banner",
  ITnkAdListener(
    onLoad: () => print("banner onLoad"),
    onShow: () => print("banner onShow"),
    onClick: () => print("banner onClick"),
    onClose: (type) {},
    onVideoCompletion: (code) {},
    onError: (code, msg) => print("banner onError $code $msg"),
  ),
);

// 배너 위젯 배치 (640x200 소재 → 폭에 맞춰 높이 = 폭 * 200/640 자동)
TnkBannerAdView(
  placementId: "home_banner",
  width: MediaQuery.of(context).size.width,
  aspectRatio: 640 / 200,
)
```

> **특정 픽셀 높이를 강제하고 싶다면** `height` 를 주면 됩니다(이 경우 `aspectRatio` 는
> 무시되고 소재는 그 박스 안에 비율을 유지한 채 배치됩니다). 다만 박스 비율이 소재 비율과
> 다르면 위/아래 여백이 생길 수 있으므로, 되도록 `aspectRatio` 로 소재 비율을 맞추는 것을
> 권장합니다.
>
> ```dart
> TnkBannerAdView(placementId: "home_banner", width: w, height: 100);
> ```

### 배너 재요청(새 광고 로드)

`TnkBannerAdView` 는 `key` 가 바뀌면 PlatformView 가 재생성되면서 네이티브 배너가 다시
`load` 됩니다. 버튼을 누를 때마다 새 광고를 받으려면 `ValueKey` 값을 바꿔주면 됩니다.

```dart
int _reload = 0;
// ...
TnkBannerAdView(
  key: ValueKey('banner_$_reload'),
  placementId: "home_banner",
);
// setState(() => _reload++); 로 재요청
```

### 하이브리드 컴포지션 (선택)

배너 내부에 WebView/미디어가 포함되어 렌더링·터치 이슈가 있는 경우에만 Android 한정으로
`useHybridComposition: true` 를 사용합니다. (기본값 false = Texture Layer, 대부분 이 값으로 충분)

```dart
TnkBannerAdView(placementId: "home_banner", useHybridComposition: true);
```

> 동일한 `placementId` 로 배너를 여러 개 노출할 수 있습니다. 이때 리스너는 placementId
> 기준으로 등록되므로 한 번만 등록하면 되고, 각 위젯은 서로 다른 `key` 를 주어 개별적으로
> 생성/로드되게 합니다.

---

# 앱 등록 및 광고 등록

테스트 광고 출력에 성공하셨다면 다음 단계를 따릅니다.

## 1. 홈페이지 가입 및 앱 등록
[티엔케이팩토리 홈페이지](https://tnkfactory.com/)로 이동 후 회원가입을 진행하고 앱을 등록합니다.

**이 과정은 영업팀의 안내를 받아 진행하시는 것을 권장합니다.**

앱 등록 후 pub id 를 발급받아 위 [Android 프로젝트 설정](#android-프로젝트-설정)처럼
`AndroidManifest.xml` 에 `tnk_pub_id` 로 추가합니다. 실제 ID 를 등록하면 테스트 코드에서는
더 이상 광고가 나타나지 않으며, Tnk Publish Site 에서 광고 유형에 맞춰 Placement 를 등록하고
그 이름을 `placementId` 로 사용해야 실제 광고가 표시됩니다.

## 2. 테스트 광고 등록
콘솔에서 테스트 광고를 등록한 뒤, 발급된 placement id 를 위 각 기능의 `placementId` 자리에
사용합니다.

## 3. 테스트 단말기 등록
개발 단계에서 광고를 출력하려면 테스트 단말기 등록이 필요합니다.

링크 : [테스트 단말기 등록방법](https://github.com/tnkfactory/android-sdk/blob/master/reg_test_device.md)

모든 단계를 마친 후 등록한 placement id 로 광고가 출력되었다면 성공입니다.
