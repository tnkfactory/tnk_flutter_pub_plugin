package com.tnkfactory.flutter.pub

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.tnkfactory.ad.AdError
import com.tnkfactory.ad.AdItem
import com.tnkfactory.ad.AdListener
import com.tnkfactory.ad.InterstitialAdItem
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject


/** TnkFlutterPubPlugin */
class TnkFlutterPubPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tnk_flutter_pub")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "showInterstitial") {
            val placementId = call.arguments as String
            InterstitialAdItem(context, placementId).apply {
                setListener(object : AdListener() {
                    override fun onLoad(adItem: AdItem?) {
                        super.onLoad(adItem)
                        adItem?.show()
                        result.success("onShow")

                        JSONObject().apply {
                            put("placementId", placementId)
                            put("event", "onLoad")
                        }.also {
                            channel.invokeMethod("TnkPubAdListener", it.toString())
                        }
                    }

                    override fun onClose(adItem: AdItem?, type: Int) {
                        super.onClose(adItem, type)
                        if (type == 2) {
                            (context as Activity).finish()
                        }
                        JSONObject().apply {
                            put("type", type.toString())
                            put("placementId", placementId)
                            put("event", "onClose")
                        }.also {
                            channel.invokeMethod("TnkPubAdListener", it.toString())
                        }
                    }

                    override fun onError(adItem: AdItem?, error: AdError?) {
                        super.onError(adItem, error)
                        if (error != null) {
                            result.error("" + error.value, error.message, null)
                        } else {
                            result.error("-99", "에러가 발생했습니다.", null)
                        }
                        JSONObject().apply {
                            put("code", (error?.value ?: -99).toString())
                            put("message", error?.message ?: "에러가 발생했습니다.")
                            put("placementId", placementId)
                            put("event", "onError")
                        }.also {
                            channel.invokeMethod("TnkPubAdListener", it.toString())
                        }
                    }

                    /**
                     * 광고의 재생이 완료되었을 경우 호출됩니다.
                     * @param adItem 광고 아이템
                     * @param verifyCode 적립 여부
                     */
                    override fun onVideoCompletion(adItem: AdItem?, verifyCode: Int) {
                        super.onVideoCompletion(adItem, verifyCode)
                        JSONObject().apply {
                            put("code", verifyCode.toString())
                            put("placementId", placementId)
                            put("event", "onVideoCompletion")
                        }.also {
                            channel.invokeMethod("TnkPubAdListener", it.toString())
                        }
                    }

                    override fun onShow(adItem: AdItem?) {
                        super.onShow(adItem)
                        JSONObject().apply {
                            put("placementId", placementId)
                            put("event", "onShow")
                        }.also {
                            channel.invokeMethod("TnkPubAdListener", it.toString())
                        }
                    }
                }).also {
                    load()
                }
                Log.d("onMethodCall", call.method + " : " + call.arguments as String)
            }
        } else if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        context = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
//        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivity() {
//        TODO("Not yet implemented")
    }
}
