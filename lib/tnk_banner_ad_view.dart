import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Tnk 배너 광고를 Flutter 위젯 트리에 노출하는 PlatformView 위젯.
///
/// 내부적으로 Android 는 [AndroidView], iOS 는 [UiKitView] 로 네이티브 배너 컨테이너
/// (`viewType: tnk_flutter_pub/banner_ad`)를 렌더링한다. 컨테이너 안에서 Tnk SDK 가
/// 자체 렌더링 배너(Android `BannerAdView`, iOS `TnkBannerAdView`)를 직접 그린다.
///
/// ## 소재 비율에 맞춰 영역을 잡는다
/// Tnk SDK 는 광고를 그릴 컨테이너를 **소재 비율에 맞는 크기**로 주면 그 크기에 맞게 소재를
/// 그린다. (iOS 가이드: `height = screenWidth * 200 / 640` 처럼 폭 기준으로 높이를 계산)
/// 따라서 이 위젯은 [aspectRatio]`(가로/세로)` 로 소재 비율을 받아, 주어진 폭에 맞는 높이로
/// 영역을 잡는다. 예) 640x200 소재 → `aspectRatio: 640 / 200`, 640x100 소재 → `640 / 100`.
///
/// - 폭은 부모 제약을 그대로 쓰며(예: `Column(crossAxisAlignment: stretch)` 또는
///   `SizedBox(width: ...)`), 높이는 `폭 / aspectRatio` 로 자동 결정된다.
/// - [width] 를 주면 그 폭을 기준으로 계산한다.
/// - 특정 픽셀 높이를 강제하고 싶으면 [height] 를 준다(이 경우 [aspectRatio] 는 무시되고,
///   소재는 그 박스 안에 비율을 유지한 채(잘림 없이) 배치된다).
///
/// 광고 라이프사이클 이벤트(onLoad/onShow/onClick/onError)는 기존 `tnk_flutter_pub`
/// MethodChannel 의 `TnkPubAdListener` 콜백으로 전달되며, `placementId` 로 구분된다.
class TnkBannerAdView extends StatelessWidget {
  /// 노출할 광고의 placement(광고 지면) 아이디.
  final String placementId;

  /// 배너 소재의 가로/세로 비율. 폭에 맞춰 높이(`폭 / aspectRatio`)를 계산한다.
  /// 예) 640x200 소재 → `640 / 200`(=3.2), 640x100 소재 → `640 / 100`(=6.4).
  final double aspectRatio;

  /// 배너 영역의 폭. null 이면 부모 제약의 폭을 그대로 사용한다.
  final double? width;

  /// 배너 영역의 높이를 픽셀로 강제한다. 지정하면 [aspectRatio] 대신 이 높이가 쓰인다.
  final double? height;

  /// 하이브리드 컴포지션 사용 여부(Android 한정). 기본값은 false(Texture Layer).
  /// 배너 내부에 WebView/미디어가 포함돼 렌더링/터치 이슈가 있을 경우 true 로 설정한다.
  final bool useHybridComposition;

  const TnkBannerAdView({
    super.key,
    required this.placementId,
    this.aspectRatio = 640 / 100,
    this.width,
    this.height,
    this.useHybridComposition = false,
  });

  static const String _viewType = 'tnk_flutter_pub/banner_ad';

  @override
  Widget build(BuildContext context) {
    Widget view = _buildPlatformView();

    // 높이를 명시하면 그 크기의 고정 박스, 아니면 소재 비율(aspectRatio)로 높이를 계산한다.
    if (height != null) {
      view = SizedBox(width: width, height: height, child: view);
    } else {
      view = AspectRatio(aspectRatio: aspectRatio, child: view);
      if (width != null) {
        view = SizedBox(width: width, child: view);
      }
    }
    return view;
  }

  Widget _buildPlatformView() {
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
