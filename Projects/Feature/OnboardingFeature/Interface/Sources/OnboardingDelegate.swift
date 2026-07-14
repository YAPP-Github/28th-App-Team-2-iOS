import Foundation

/// OnboardingFeature 외부와 통신하기 위한 델리게이트 명세입니다.
/// App 레이어 (또는 부모 라우터)에서 이 프로토콜을 구현하여 이벤트를 처리합니다.
public protocol OnboardingDelegate: AnyObject {
    func onboardingDidFinish()
}
