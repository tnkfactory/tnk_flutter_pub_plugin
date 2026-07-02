import Flutter
import UIKit
import TnkPubSdk
import AppTrackingTransparency

/// Tnk 배너 광고를 담는 iOS PlatformView.
///
/// 빈 컨테이너 UIView 안에 자체 렌더링 배너 뷰 `TnkBannerAdView` 를 추가하고 load 한다.
/// 광고 UI 는 SDK 가 직접 그린다. 라이프사이클 이벤트는 기존 `TnkPubAdListener` 채널 규약
/// (JSON 문자열)으로 Flutter 에 전달한다.
class TnkBannerAdPlatformView: NSObject, FlutterPlatformView, TnkAdListener {

    private let placementId: String
    private let container: UIView
    private var bannerAdView: TnkBannerAdView?

    init(frame: CGRect, placementId: String) {
        self.placementId = placementId
        self.container = UIView(frame: frame)
        super.init()

        // container 는 Flutter 가 frame 으로 크기를 지정하는 뷰다(translatesAutoresizingMaskIntoConstraints=true 여야 함).
        // Tnk SDK 의 setContainerView(_:) 는 넘겨받은 뷰의 tAMIC 를 false 로 바꾸고 제약을 추가하므로,
        // container 를 직접 넘기면 Flutter 가 준 frame 이 무시되어 크기가 0 으로 붕괴한다.
        // 따라서 내부 컨테이너(inner)를 두고 container 가장자리에 제약으로 고정해 같은 크기를 상속받게 한 뒤,
        // setContainerView 에는 inner 를 넘겨 SDK 의 tAMIC 변경이 Flutter 사이징에 영향을 주지 않도록 격리한다.
        let inner = UIView()
        inner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            inner.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            inner.topAnchor.constraint(equalTo: container.topAnchor),
            inner.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        let banner = TnkBannerAdView(placementId: placementId, adListener: self)
        banner.translatesAutoresizingMaskIntoConstraints = false
        inner.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: inner.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: inner.trailingAnchor),
            banner.topAnchor.constraint(equalTo: inner.topAnchor),
            banner.bottomAnchor.constraint(equalTo: inner.bottomAnchor),
        ])
        banner.setContainerView(inner)

        self.bannerAdView = banner

        // 전면광고와 동일하게 ATT(추적 허용)를 요청하고, 응답 이후 배너를 load 한다.
        // (IDFA 확보 시 광고 fill 향상. 팝업은 앱 생애 최초 1회만 노출됨)
        requestTrackingThenLoad(banner)
    }

    private func requestTrackingThenLoad(_ banner: TnkBannerAdView) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    banner.load()
                }
            }
        } else {
            banner.load()
        }
    }

    func view() -> UIView {
        return container
    }

    // MARK: - TnkAdListener

    func onLoad(_ adItem: TnkAdItem) {
        sendEvent(["placementId": placementId, "event": "onLoad"])
        // load() 로 광고를 받아온 뒤에는 show() 를 호출해야 실제로 배너가 렌더링된다.
        // (전면광고와 동일한 load -> onLoad -> show 흐름. show 없이는 onShow 도 오지 않음)
        DispatchQueue.main.async { [weak self] in
            self?.bannerAdView?.show()
            // 배너 영역이 박스보다 작을 때 SDK 가 남는 공간을 검은색으로 채워
            // letterbox(검정 배경)가 보이는 문제를 없앤다. 소재 이미지 자체는 영향 없음.
            self?.clearBackgrounds()
        }
        // show 이후 SDK 가 뒤늦게 배경을 다시 칠하는 경우까지 처리
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.clearBackgrounds()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.clearBackgrounds()
        }
    }

    /// 컨테이너/배너 및 하위 뷰의 불투명 배경을 투명으로 바꿔 검정 letterbox 를 제거한다.
    private func clearBackgrounds() {
        container.backgroundColor = .clear
        container.isOpaque = false
        guard let banner = bannerAdView else { return }
        func clear(_ v: UIView) {
            v.backgroundColor = .clear
            v.isOpaque = false
            for sv in v.subviews { clear(sv) }
        }
        // 배너와 그 부모(inner)까지 투명 처리
        banner.superview?.backgroundColor = .clear
        clear(banner)
    }

    func onShow(_ adItem: TnkAdItem) {
        sendEvent(["placementId": placementId, "event": "onShow"])
    }

    func onClick(_ adItem: TnkAdItem) {
        sendEvent(["placementId": placementId, "event": "onClick"])
    }

    func onError(_ adItem: TnkAdItem, error: AdError) {
        sendEvent([
            "placementId": placementId,
            "event": "onError",
            "code": String(error.rawValue),
            "message": String(error.rawValue) + error.description(),
        ])
    }

    // MARK: - Event helper

    private func sendEvent(_ data: [String: String]) {
        var jsonString = ""
        do {
            let json = try JSONSerialization.data(withJSONObject: data)
            jsonString = String(data: json, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        SwiftTnkFlutterPubPlugin.channel?.invokeMethod("TnkPubAdListener", arguments: jsonString)
    }
}
