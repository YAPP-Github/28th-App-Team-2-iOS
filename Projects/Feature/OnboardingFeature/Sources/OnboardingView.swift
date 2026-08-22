import ComposableArchitecture
import DesignSystem
import SwiftUI
import WebKit

public struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    #if DEBUG
    @State var isDebugPreviewSheetPresented = false
    @State var pendingDebugPreview: DebugPreview?
    #endif

    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    public var body: some View {
        onboardingContent
            .overlay {
                if store.isSignupExpirationDialogPresented {
                    signupExpirationDialog
                }
            }
        #if DEBUG
            .sheet(
                isPresented: $isDebugPreviewSheetPresented,
                onDismiss: applyPendingDebugPreview
            ) {
                DebugPreviewSheet { preview in
                    pendingDebugPreview = preview
                }
            }
        #endif
    }

    @ViewBuilder
    private var onboardingContent: some View {
        switch store.route {
        case .login:
            loginView
        case .onboarding:
            onboardingView
        case .home:
            EmptyView()
        }
    }

    @ViewBuilder
    private var onboardingView: some View {
        switch store.onboardingStep {
        case .terms:
            termsAgreementView
        case .name:
            onboardingNameView
        case .fortuneInformation:
            FortuneInformationView(store: store)
        case .userStatus:
            UserStatusView(store: store)
        }
    }

    private var loginView: some View {
        VStack(spacing: 0) {
            Spacer()

            OnboardingFeatureAsset.Brand.onboardingCharacter.swiftUIImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 164, height: 160)

            OnboardingFeatureAsset.Brand.typoLogoColor.swiftUIImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 226, height: 66)
                .padding(.top, 29)

            Text("당신의 운세 도우미, 토닥운")
                .dsBody1Medium
                .foregroundStyle(Color(red: 55 / 255, green: 60 / 255, blue: 70 / 255))
                .padding(.top, 18)

            Spacer()

            VStack(spacing: 12) {
                socialLoginButton(
                    SocialLoginButtonConfiguration(
                        title: "카카오톡으로 시작하기",
                        provider: .kakao,
                        iconAsset: OnboardingFeatureAsset.Icons.oauthKakao,
                        iconSize: CGSize(width: 21, height: 20),
                        backgroundColor: Color(red: 250 / 255, green: 227 / 255, blue: 1 / 255),
                        foregroundColor: .black
                    )
                )
                socialLoginButton(
                    SocialLoginButtonConfiguration(
                        title: "Google로 시작하기",
                        provider: .google,
                        iconAsset: OnboardingFeatureAsset.Icons.oauthGoogle,
                        iconSize: CGSize(width: 20, height: 20),
                        backgroundColor: Color(red: 241 / 255, green: 243 / 255, blue: 245 / 255),
                        foregroundColor: Color(red: 33 / 255, green: 33 / 255, blue: 33 / 255)
                    )
                )
                socialLoginButton(
                    SocialLoginButtonConfiguration(
                        title: "Apple로 시작하기",
                        provider: .apple,
                        iconAsset: OnboardingFeatureAsset.Icons.oauthApple,
                        iconSize: CGSize(width: 24, height: 24),
                        backgroundColor: .black,
                        foregroundColor: .white
                    )
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

        }
        .padding(.horizontal, 20)
        .padding(.top, 52)
        .padding(.bottom, 78)
        .background(Color.white)
        .overlay {
            if store.loginPhase.isLoading {
                ProgressView("로그인 중…")
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            debugPreviewMenuButton
                .padding(.top, 12)
                .padding(.trailing, 20)
        }
        #endif
    }

    #if DEBUG
    private func applyPendingDebugPreview() {
        guard let pendingDebugPreview else { return }
        self.pendingDebugPreview = nil
        store.send(.debugPreviewButtonTapped(pendingDebugPreview))
    }
    #endif

    private func socialLoginButton(_ configuration: SocialLoginButtonConfiguration) -> some View {
        Button {
            store.send(.socialLoginButtonTapped(configuration.provider))
        } label: {
            HStack(spacing: 14) {
                configuration.iconAsset.swiftUIImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: configuration.iconSize.width, height: configuration.iconSize.height)

                Text(configuration.title)
                    .dsBody2Medium
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .foregroundStyle(configuration.foregroundColor)
            .background(configuration.backgroundColor, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .disabled(store.loginPhase.isLoading)
    }

    private var onboardingNameView: some View {
        VStack(spacing: 0) {
            DSProgressBar(progress: 0.25) {
                store.send(.onboardingBackButtonTapped)
            }

            VStack(alignment: .leading, spacing: 32) {
                Text(onboardingNameTitle)
                    .dsHeading2SemiBold

                DSEnterName(
                    text: Binding(
                        get: { store.onboardingName },
                        set: { store.send(.onboardingNameChanged($0)) }
                    ),
                    validationState: nameValidationState
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 64)

            Spacer()

            DSPrimaryLargeButton("다음") {
                store.send(.onboardingNameNextButtonTapped)
            }
            .disabled(!store.isOnboardingNameValid)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
    }

    private var nameValidationState: DSTextFieldValidationState {
        guard let message = store.onboardingNameValidationMessage else {
            return .none
        }
        return .error(message: message)
    }

    private var onboardingNameTitle: AttributedString {
        var title = AttributedString("안녕하세요!\n이름을 입력해 주세요.")
        title.font = .ds.font(.heading2SemiBold)
        title.foregroundColor = Color.ds.gray975

        if let nameRange = title.range(of: "이름") {
            title[nameRange].font = .ds.font(.heading2Bold)
            title[nameRange].foregroundColor = Color.ds.primary700
        }

        return title
    }

    private var signupExpirationDialog: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            DSDialog(
                title: "인증 정보가 만료되었어요",
                message: "처음부터 다시 로그인해 주세요.",
                primaryAction: DSDialog.Action(
                    "확인",
                    handler: {
                        store.send(.signupExpirationDialogConfirmed)
                    }
                )
            )
        }
        .accessibilityAddTraits(.isModal)
    }

}

private struct SocialLoginButtonConfiguration {
    let title: String
    let provider: SocialProvider
    let iconAsset: OnboardingFeatureImages
    let iconSize: CGSize
    let backgroundColor: Color
    let foregroundColor: Color
}

private extension OnboardingView {
    var termsAgreementView: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: "약관 동의",
                leftItem: DSHeaderActionItem(
                    identifier: "back-to-login",
                    icon: .chevronLeftPlain,
                    action: { store.send(.onboardingBackButtonTapped) }
                )
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("토닥운 이용을 위해\n동의가 필요해요")
                        .dsHeading2SemiBold
                        .foregroundStyle(Color.ds.gray975)
                        .padding(.top, 48)

                    VStack(spacing: 20) {
                        ForEach(store.terms) { term in
                            termRow(term)
                        }
                    }
                    .padding(.top, 44)

                    Rectangle()
                        .fill(Color.ds.gray100)
                        .frame(height: 1)
                        .padding(.vertical, 24)

                    DSCheckboxRow(
                        isOn: Binding(
                            get: { store.isAllTermsAgreed },
                            set: { store.send(.allTermsAgreementToggled($0)) }
                        ),
                        minimumIndicatorSpacing: 12
                    ) {
                        Text("전체 동의하기")
                            .dsBody1Bold
                            .foregroundStyle(Color.ds.gray975)
                    }
                }
                .padding(.horizontal, 20)
            }

            DSPrimaryLargeButton("다음") {
                store.send(.termsNextButtonTapped)
            }
            .disabled(!store.areRequiredTermsAgreed)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .overlay {
            if store.isOnboardingExitConfirmationPresented {
                exitConfirmationDialog
            }
        }
        .sheet(
            item: Binding(
                get: { store.selectedTermDetail },
                set: { _ in store.send(.termDetailDismissed) }
            )
        ) { term in
            TermsDetailView(term: term)
        }
    }

    var exitConfirmationDialog: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { store.send(.onboardingExitConfirmationDismissed) }

            DSDialog(
                title: "지금 나가면 가입이 취소돼요",
                message: "동의하신 약관 정보는 저장되지 않아요.",
                primaryAction: DSDialog.Action(
                    "계속하기",
                    handler: { store.send(.onboardingExitConfirmationDismissed) }
                ),
                secondaryAction: DSDialog.Action(
                    "나가기",
                    handler: { store.send(.onboardingExitConfirmed) }
                )
            )
        }
        .accessibilityAddTraits(.isModal)
    }

    func termAgreementBinding(for term: OnboardingTerm) -> Binding<Bool> {
        Binding(
            get: { term.isAgreed },
            set: { store.send(.termAgreementToggled(term.id, $0)) }
        )
    }

    func termRow(_ term: OnboardingTerm) -> some View {
        HStack(spacing: 12) {
            DSCheckbox(isOn: termAgreementBinding(for: term))

            Button {
                store.send(.termDetailButtonTapped(term.id))
            } label: {
                HStack(spacing: 8) {
                    Text(termTitle(term))
                        .dsBody3Regular
                        .foregroundStyle(Color.ds.black)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 12)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.ds.gray500)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(termTitle(term)) 상세 보기")
        }
    }

    func termTitle(_ term: OnboardingTerm) -> String {
        "(\(term.isRequired ? "필수" : "선택")) \(term.title)"
    }
}
