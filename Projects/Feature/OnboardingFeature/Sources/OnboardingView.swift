import ComposableArchitecture
import DesignSystem
import SwiftUI
import WebKit

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

    private var onboardingNameView: some View {
        VStack(spacing: 0) {
            DSProgressBar(progress: 0.25) {
                store.send(.onboardingBackButtonTapped)
            }

            VStack(alignment: .leading, spacing: 32) {
                Text("안녕하세요!\n이름을 입력해 주세요.")
                    .dsHeading2SemiBold
                    .foregroundStyle(Color.ds.gray975)

                DSEnterName(
                    text: Binding(
                        get: { store.onboardingName },
                        set: { store.send(.onboardingNameChanged($0)) }
                    )
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
                        .foregroundStyle(Color.ds.gray800)
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

private struct TermsDetailView: View {
    let term: OnboardingTerm

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: "약관 동의",
                leftItem: DSHeaderActionItem(
                    identifier: "close-term-detail",
                    icon: .chevronLeftPlain,
                    action: { dismiss() }
                )
            )

            TermsWebView(urlString: term.detailURLString)
        }
    }
}

private struct TermsWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString), webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }
}
