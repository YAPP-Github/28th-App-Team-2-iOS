import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct OnboardingView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>

    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    public var body: some View {
        switch store.route {
        case .login:
            loginView
        case .onboarding:
            onboardingHandoffView
        case .home:
            EmptyView()
        }
    }

    private var loginView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 10) {
                Text("토닥운")
                    .dsHeading1ExtraBold
                    .foregroundStyle(Color.ds.primary600)
                Text("당신의 운세 도우미")
                    .dsBody1Medium
                    .foregroundStyle(Color.ds.gray700)
            }

            Spacer()

            VStack(spacing: 12) {
                socialLoginButton(
                    title: "카카오톡으로 시작하기",
                    provider: .kakao,
                    backgroundColor: Color(red: 250 / 255, green: 227 / 255, blue: 1 / 255),
                    foregroundColor: .black
                )
                socialLoginButton(
                    title: "Google로 시작하기",
                    provider: .google,
                    backgroundColor: Color.ds.gray100,
                    foregroundColor: Color.ds.gray900
                )
                socialLoginButton(
                    title: "Apple로 시작하기",
                    provider: .apple,
                    backgroundColor: .black,
                    foregroundColor: .white
                )
            }

            if case let .failed(error) = store.loginPhase {
                VStack(spacing: 12) {
                    Text(error.message)
                        .dsBody3Regular
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.ds.red600)
                    Button("다시 시도", action: { store.send(.retryButtonTapped) })
                        .dsBody3SemiBold
                        .foregroundStyle(Color.ds.primary600)
                }
                .padding(.top, 20)
            }

            #if DEBUG
            debugPreviewButtons
            #endif
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 48)
        .overlay {
            if store.loginPhase.isLoading {
                ProgressView("로그인 중…")
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func socialLoginButton(
        title: String,
        provider: SocialProvider,
        backgroundColor: Color,
        foregroundColor: Color
    ) -> some View {
        Button {
            store.send(.socialLoginButtonTapped(provider))
        } label: {
            Text(title)
                .dsBody2Medium
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(foregroundColor)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8))
        }
        .disabled(store.loginPhase.isLoading)
    }

    private var onboardingHandoffView: some View {
        VStack(spacing: 16) {
            Text("회원가입을 이어갈 준비가 됐어요")
                .dsHeading3Bold
            Text("다음 작업에서 약관 동의와 정보를 입력하는 화면이 연결됩니다.")
                .dsBody3Regular
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.ds.gray600)
        }
        .padding(24)
    }

    #if DEBUG
    private var debugPreviewButtons: some View {
        VStack(spacing: 8) {
            Text("개발용 흐름 미리 보기")
                .dsCaption1Medium
                .foregroundStyle(Color.ds.gray500)
            Button("신규 회원 온보딩 보기") {
                store.send(.debugPreviewButtonTapped(.newMember))
            }
            Button("기존 회원 홈 보기") {
                store.send(.debugPreviewButtonTapped(.existingMember))
            }
        }
        .padding(.top, 24)
    }
    #endif
}
