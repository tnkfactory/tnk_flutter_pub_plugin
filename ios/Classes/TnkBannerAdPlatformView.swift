import Flutter
import UIKit
import TnkPubSdk
import AppTrackingTransparency

/// Flutter 가 frame 으로 크기를 지정하는 PlatformView 루트 뷰.
/// 화면에 실제로 올라오고(window) 크기가 잡히는(layoutSubviews) 시점을 콜백으로 알려,
/// 그 순간에 배너 `show()` 를 호출할 수 있게 한다. (폴링으로는 놓치는 경합 방지)
final class BannerContainerView: UIView {
    /// window 에 존재하고 실제 크기를 가진 상태로 레이아웃될 때마다 호출된다.
    var onBecameVisible: (() -> Void)?

    private func notifyIfVisible() {
        if window != nil, bounds.width > 0, bounds.height > 0 {
            onBecameVisible?()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        notifyIfVisible()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        notifyIfVisible()
    }
}

/// Tnk 배너 광고를 담는 iOS PlatformView.
///
/// `TnkBannerAdView` 는 뷰 계층에 직접 올리지 않는다. 대신 렌더 대상 뷰(renderView)를
/// `setContainerView(_:)` 로 넘기면 SDK 가 그 뷰 크기에 맞춰 소재를 그린다.
/// 따라서 Flutter 위젯이 **소재 비율에 맞는 크기**(예: 640x200 → 폭 x 폭*200/640)로 박스를
/// 잡아주면, SDK 가 그 크기대로 소재를 채운다. (별도 스케일 변환 없음 — iOS 연동 가이드와 동일)
///
/// 라이프사이클 이벤트는 기존 `TnkPubAdListener` 채널 규약(JSON 문자열)으로 Flutter 에 전달한다.
class TnkBannerAdPlatformView: NSObject, FlutterPlatformView, TnkAdListener {

    private let placementId: String
    /// Flutter 가 frame 으로 크기를 지정하는 PlatformView 루트 뷰.
    private let container: BannerContainerView
    /// SDK 가 소재를 그리는 대상 뷰(tAMIC 격리용).
    private let renderView: UIView
    private var bannerAdView: TnkBannerAdView?

    /// onLoad(광고 로드 완료) 여부. 화면 부착과 순서가 뒤바뀔 수 있어 플래그로 관리한다.
    private var isLoaded = false
    /// load() 를 이미 호출했는지. (화면에 보이게 된 뒤 한 번만 로드)
    private var didStartLoad = false
    /// show() 를 이미 호출했는지. 중복 show(DupShow) 방지.
    private var didShow = false

    init(frame: CGRect, placementId: String) {
        self.placementId = placementId
        self.container = BannerContainerView(frame: frame)
        self.renderView = UIView()
        super.init()

        // 박스를 넘치는 소재(cover)를 잘라내기 위해 clip 필수.
        container.clipsToBounds = true
        renderView.clipsToBounds = true

        // container 는 Flutter 가 frame 으로 크기를 주는 뷰다(tAMIC=true 여야 함).
        // SDK 의 setContainerView(_:) 는 넘겨받은 뷰의 tAMIC 를 false 로 바꾸고 제약을 추가하므로,
        // container 를 직접 넘기면 Flutter 가 준 frame 이 무시되어 크기가 0 으로 붕괴한다.
        // 따라서 renderView 를 container 가장자리에 제약으로 고정해 같은 크기(= Flutter 박스)를
        // 상속받게 한 뒤, SDK 에는 renderView 를 넘겨 격리한다.
        renderView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(renderView)
        NSLayoutConstraint.activate([
            renderView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            renderView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            renderView.topAnchor.constraint(equalTo: container.topAnchor),
            renderView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        // 컨테이너가 화면에 올라오고 실제 크기를 가진 뒤에 setContainerView + load / show 를 한다.
        // setContainerView 를 미루는 이유: SDK 는 setContainerView 시점의 컨테이너 크기를 캡처하는데,
        // init 에서 부르면 Auto Layout 전이라 크기가 0 이라 이후 계속 "not visible" 로 판단된다.
        container.onBecameVisible = { [weak self] in
            self?.configureAndLoadIfNeeded()
            self?.tryShow()
        }

        // 배너는 addSubview 하지 않는다. setContainerView 로 넘긴 renderView 에 SDK 가 직접 그린다.
        let banner = TnkBannerAdView(placementId: placementId, adListener: self)
        banner.setValue("da_id", value: placementId)
        self.bannerAdView = banner
    }

    /// 컨테이너(renderView)가 실제 크기를 가진 뒤 딱 한 번 setContainerView + load 를 수행한다.
    private func configureAndLoadIfNeeded() {
        guard !didStartLoad, let banner = bannerAdView else { return }
        container.layoutIfNeeded()
        guard renderView.bounds.width > 0, renderView.bounds.height > 0 else { return }

        didStartLoad = true
        banner.setContainerView(renderView)
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

    deinit {
        let banner = bannerAdView
        DispatchQueue.main.async { banner?.close() }
    }

    /// 광고 로드가 끝났고 컨테이너가 화면에 실제로 보일 때 딱 한 번 show() 한다.
    private func tryShow() {
        guard isLoaded, !didShow else { return }
        guard renderView.window != nil,
              renderView.bounds.width > 0,
              renderView.bounds.height > 0 else { return }

        didShow = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.container.isHidden = false
            self.renderView.isHidden = false
            self.renderView.alpha = 1
            self.bannerAdView?.show()
            self.scheduleClearBackgrounds()
        }
    }

    /// 렌더 타이밍이 제각각이라 여러 시점에 배경 투명화를 시도한다.(letterbox 잔상 제거)
    private func scheduleClearBackgrounds() {
        clearBackgrounds()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.clearBackgrounds()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.clearBackgrounds()
        }
    }

    /// renderView 와 그 하위(SDK 소재)의 불투명 배경을 투명으로 바꿔 letterbox 를 제거한다.
    private func clearBackgrounds() {
        container.backgroundColor = .clear
        container.isOpaque = false
        func clear(_ v: UIView) {
            v.backgroundColor = .clear
            v.isOpaque = false
            for sv in v.subviews { clear(sv) }
        }
        clear(renderView)
    }

    // MARK: - TnkAdListener

    func onLoad(_ adItem: TnkAdItem) {
        sendEvent(["placementId": placementId, "event": "onLoad"])
        DispatchQueue.main.async { [weak self] in
            self?.isLoaded = true
            self?.container.setNeedsLayout()
            self?.tryShow()
        }
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
