package com.tnkfactory.flutter.pub

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * `tnk_flutter_pub/banner_ad` PlatformView 를 생성하는 팩토리.
 * Flutter 의 creationParams 에서 placementId 를 받아 [TnkBannerAdPlatformView] 를 만든다.
 * 광고 이벤트 전송을 위해 플러그인의 [MethodChannel] 을 넘겨받는다.
 */
class TnkBannerAdViewFactory(
    private val channel: MethodChannel,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?> ?: emptyMap()
        val placementId = params["placementId"] as? String ?: ""
        return TnkBannerAdPlatformView(context, placementId, channel)
    }
}
