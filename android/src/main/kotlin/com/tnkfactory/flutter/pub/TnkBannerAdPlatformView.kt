package com.tnkfactory.flutter.pub

import android.content.Context
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.tnkfactory.ad.AdError
import com.tnkfactory.ad.AdItem
import com.tnkfactory.ad.AdListener
import com.tnkfactory.ad.BannerAdView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import org.json.JSONObject

/**
 * Tnk 배너 광고를 담는 PlatformView.
 *
 * 빈 컨테이너([FrameLayout]) 안에 자체 렌더링 배너 뷰 [BannerAdView] 를 추가하고 load 한다.
 * 광고 UI 는 SDK 가 직접 그린다. 라이프사이클 이벤트는 기존 `TnkPubAdListener` 채널 규약
 * (JSON 문자열)으로 Flutter 에 전달한다.
 */
class TnkBannerAdPlatformView(
    context: Context,
    private val placementId: String,
    private val channel: MethodChannel,
) : PlatformView {

    private val container: FrameLayout = FrameLayout(context)
    private val bannerAdView: BannerAdView = BannerAdView(context, placementId)

    init {
        val lp = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
        ).apply { gravity = Gravity.CENTER }
        container.addView(bannerAdView, lp)

        bannerAdView.setListener(object : AdListener() {
            override fun onLoad(adItem: AdItem?) {
                super.onLoad(adItem)
                sendEvent("onLoad")
            }

            override fun onShow(adItem: AdItem?) {
                super.onShow(adItem)
                sendEvent("onShow")
            }

            override fun onClick(adItem: AdItem?) {
                super.onClick(adItem)
                sendEvent("onClick")
            }

            override fun onError(adItem: AdItem?, error: AdError?) {
                super.onError(adItem, error)
                sendError(error)
            }
        })

        Log.d("TnkBannerAdView", "load : $placementId")
        bannerAdView.load()
    }

    private fun sendEvent(event: String) {
        JSONObject().apply {
            put("placementId", placementId)
            put("event", event)
        }.also {
            channel.invokeMethod("TnkPubAdListener", it.toString())
        }
    }

    private fun sendError(error: AdError?) {
        JSONObject().apply {
            put("code", (error?.value ?: -99).toString())
            put("message", error?.message ?: "에러가 발생했습니다.")
            put("placementId", placementId)
            put("event", "onError")
        }.also {
            channel.invokeMethod("TnkPubAdListener", it.toString())
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        bannerAdView.close()
    }
}
