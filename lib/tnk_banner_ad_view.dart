import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Tnk 배너 광고를 Flutter 위젯 트리에 노출하는 PlatformView 위젯.
///
/// 내부적으로 Android 는 [AndroidView], iOS 는 [UiKitView] 로 네이티브 배너 컨테이너
/// (`viewType: tnk_flutter_pub/banner_ad`)를 렌더링한다. 컨테이너 안에는 Tnk SDK 의
/// 자체 렌더링 배너 뷰(Android `BannerAdView`, iOS `TnkBannerAdView`)가 추가되며,
/// 광고 UI 는 SDK 가 직접 그린다.
///
/// 광고 라이프사이클 이벤트(onLoad/onShow/onClick/onError)는 기존 `tnk_flutter_pub`
/// MethodChannel 의 `TnkPubAdListener` 콜백으로 전달되며, `placementId` 로 구분된다.
/// 앱에서 해당 채널 핸들러(예: `TnkFlutterPubEventHandler`)에 `placementId` 리스너를
/// 등록해두면 이 위젯이 노출하는 광고의 이벤트를 받을 수 있다.
///
/// 배너는 자체 콘텐츠 크기를 가지므로, 호출측에서 [SizedBox]/[Container] 등으로
/// 영역을 지정해 사용한다.
class TnkBannerAdView extends StatelessWidget {
  /// 노출할 광고의 placement(광고 지면) 아이디.
  final String placementId;

  /// 하이브리드 컴포지션 사용 여부(Android 한정). 기본값은 false(Texture Layer).
  /// 배너 내부에 WebView/미디어가 포함돼 렌더링/터치 이슈가 있을 경우 true 로 설정한다.
  final bool useHybridComposition;

  const TnkBannerAdView({
    super.key,
    required this.placementId,
    this.useHybridComposition = false,
  });

  static const String _viewType = 'tnk_flutter_pub/banner_ad';

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'placementId': placementId,
    };

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (useHybridComposition) {
          return PlatformViewLink(
            viewType: _viewType,
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: _viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () => params.onFocusChanged(true),
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..create();
            },
          );
        }
        return AndroidView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
