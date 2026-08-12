import ComposableArchitecture
import DesignSystem
import SafariServices
import SwiftUI

struct MyPageAppSettingsView: View {
    @Bindable var store: StoreOf<MyPageFeature>
    @State private var selectedLegalDocument: LegalDocument?

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: "앱 설정",
                leftItem: DSHeaderActionItem(
                    identifier: "app-settings-back",
                    icon: .chevronLeftPlain,
                    action: { store.send(.accountSettings(.dismissAppSettings)) }
                )
            )

            VStack(spacing: 0) {
                settingRow("개인정보 처리방침") {
                    selectedLegalDocument = .privacyPolicy
                }
                Divider().foregroundStyle(Color.ds.gray100)
                settingRow("서비스 이용약관") {
                    selectedLegalDocument = .serviceTerms
                }
                Divider().foregroundStyle(Color.ds.gray100)
                settingRow("회원 탈퇴") {
                    store.send(.accountSettings(.withdrawalTapped))
                }
            }
            .padding(.top, 20)

            Spacer(minLength: 0)
        }
        .background(Color.ds.white.ignoresSafeArea())
        .fullScreenCover(item: $selectedLegalDocument) { document in
            SafariSheet(url: document.url)
                .ignoresSafeArea()
        }
    }

    private func settingRow(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .dsBody2Medium
                    .foregroundStyle(Color.ds.gray975)
                Spacer(minLength: 0)
                DSIcon(.chevronSmallRight, width: 20, height: 20)
                    .foregroundStyle(Color.ds.gray400)
            }
            .frame(height: 56)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
    }

}

private enum LegalDocument: Identifiable {
    case privacyPolicy
    case serviceTerms

    // swiftlint:disable:next identifier_name
    var id: Self { self }

    var url: URL {
        switch self {
        case .privacyPolicy:
            URL(string: "https://app.notion.com/p/3b081c6748468045a408eb20d27e2342?source=copy_link")!
        case .serviceTerms:
            URL(string: "https://app.notion.com/p/3b081c67484680aca6e5ec1d463c670d?source=copy_link")!
        }
    }
}

private struct SafariSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}

struct MyPageWithdrawalReasonView: View {
    @Bindable var store: StoreOf<MyPageFeature>

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: "회원 탈퇴",
                leftItem: DSHeaderActionItem(
                    identifier: "withdrawal-reason-back",
                    icon: .chevronLeftPlain,
                    action: { store.send(.accountSettings(.dismissWithdrawal)) }
                )
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("서비스를 이용하는데\n불편함이 있으셨나요?")
                        .dsHeading3Bold
                        .foregroundStyle(Color.ds.gray975)
                        .padding(.top, 36)

                    Text("회원 탈퇴 시, 토닥운 내 모든 서비스 이용 정보가 삭제되며,\n삭제된 계정은 복구되지 않아요.")
                        .dsBody3Regular
                        .foregroundStyle(Color.ds.gray600)
                        .padding(.top, 12)

                    DSSelectField(
                        selection: selectedReasonTitle,
                        placeholder: "탈퇴 사유 선택",
                        action: { store.send(.accountSettings(.reasonFieldTapped)) }
                    )
                    .padding(.top, 40)

                    if store.withdrawal?.reason != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(
                                store.withdrawal?.reason?.requiresDetail == true
                                    ? "상세 사유를 입력해 주세요."
                                    : "(선택) 상세 사유를 입력해 주세요."
                            )
                                .dsBody2Medium
                                .foregroundStyle(Color.ds.gray975)

                            DSTextField(
                                text: detail,
                                placeholder: "상세 사유 입력",
                                validationState: detailValidation
                            )

                            HStack {
                                if store.withdrawal?.reason?.requiresDetail == true {
                                    Text("기타 사유는 상세 내용을 입력해 주세요.")
                                        .dsCaption1Regular
                                        .foregroundStyle(Color.ds.gray600)
                                }
                                Spacer(minLength: 0)
                                Text("\(store.withdrawal?.detail.count ?? 0)/200")
                                    .dsCaption1Regular
                                    .foregroundStyle(Color.ds.gray500)
                            }
                        }
                        .padding(.top, 28)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            DSPrimaryLargeButton("다음") {
                store.send(.accountSettings(.nextTapped))
            }
            .disabled(store.withdrawal?.canProceed != true)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .background(Color.ds.white.ignoresSafeArea())
        .dsWheelPickerSheet(
            isPresented: isReasonSheetPresented,
            layout: .single,
            title: "탈퇴 사유 선택",
            onSave: { store.send(.accountSettings(.saveReason)) },
            content: {
                DSSingleWheelPicker(
                    items: reasonItems,
                    selection: draftReasonIndex,
                    accessibilityLabel: "탈퇴 사유"
                )
            }
        )
    }

    private var selectedReasonTitle: Binding<String?> {
        Binding(
            get: { store.withdrawal?.reason?.title },
            set: { value in
                if value == nil {
                    store.send(.accountSettings(.clearReason))
                }
            }
        )
    }

    private var isReasonSheetPresented: Binding<Bool> {
        Binding(
            get: { store.withdrawal?.isReasonSheetPresented ?? false },
            set: { store.send(.accountSettings(.reasonSheetPresented($0))) }
        )
    }

    private var detail: Binding<String> {
        Binding(
            get: { store.withdrawal?.detail ?? "" },
            set: { store.send(.accountSettings(.detailChanged($0))) }
        )
    }

    private var detailValidation: DSTextFieldValidationState {
        store.withdrawal?.reason?.requiresDetail == true && store.withdrawal?.detail.isEmpty == true
            ? .error(message: "상세 사유를 입력해 주세요.")
            : .none
    }

    private var reasonItems: [DSWheelPickerItem] {
        WithdrawalReason.allCases.enumerated().map { index, reason in
            DSWheelPickerItem(value: index, title: reason.title)
        }
    }

    private var draftReasonIndex: Binding<Int> {
        Binding(
            get: {
                guard let draftReason = store.withdrawal?.draftReason else { return 0 }
                return WithdrawalReason.allCases.firstIndex(of: draftReason) ?? 0
            },
            set: { index in
                guard WithdrawalReason.allCases.indices.contains(index) else { return }
                store.send(.accountSettings(.draftReasonSelected(WithdrawalReason.allCases[index])))
            }
        )
    }
}

struct MyPageWithdrawalAgreementView: View {
    @Bindable var store: StoreOf<MyPageFeature>

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                DSHeaderSub(
                    title: "회원 탈퇴",
                    leftItem: DSHeaderActionItem(
                        identifier: "withdrawal-agreement-back",
                        icon: .chevronLeftPlain,
                        action: { store.send(.accountSettings(.dismissAgreement)) }
                    )
                )

                VStack(alignment: .leading, spacing: 0) {
                    Text("아래 내용 확인 후 동의해 주세요.")
                        .dsHeading3Bold
                        .foregroundStyle(Color.ds.gray975)
                        .padding(.top, 36)

                    Text("회원 탈퇴 시, 토닥운 내 모든 서비스 이용 정보가 삭제되며,\n삭제된 계정은 복구되지 않아요.")
                        .dsBody3Regular
                        .foregroundStyle(Color.ds.gray600)
                        .padding(.top, 12)

                    ScrollView {
                        Text(Self.notice)
                            .dsBody3Medium
                            .foregroundStyle(Color.ds.gray975)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                    }
                    .frame(maxHeight: 288)
                    .background(Color.ds.gray25, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 28)

                    Spacer(minLength: 0)

                    DSCheckbox(
                        isOn: isAgreed,
                        labelSpacing: 12
                    ) {
                        Text("유의 사항을 모두 확인하였으며, 동의합니다.")
                            .dsBody3Medium
                            .foregroundStyle(Color.ds.gray975)
                    }
                    .padding(.bottom, 14)

                    DSPrimaryLargeButton(store.withdrawal?.isSubmitting == true ? "처리 중…" : "회원 탈퇴하기") {
                        store.send(.accountSettings(.confirmationPresented(true)))
                    }
                    .disabled(store.withdrawal?.isAgreed != true || store.withdrawal?.isSubmitting == true)
                    .padding(.bottom, 14)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.ds.white.ignoresSafeArea())

            if store.withdrawal?.isConfirmationPresented == true {
                confirmationOverlay
            }
        }
        .alert(
            "회원 탈퇴를 완료하지 못했어요",
            isPresented: Binding(
                get: { store.withdrawal?.error != nil },
                set: { _ in store.send(.accountSettings(.dismissWithdrawalError)) }
            )
        ) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("회원 탈퇴에 실패했어요. 다시 시도해주세요.")
        }
    }

    private var isAgreed: Binding<Bool> {
        Binding(
            get: { store.withdrawal?.isAgreed ?? false },
            set: { store.send(.accountSettings(.agreementChanged($0))) }
        )
    }

    private var confirmationOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                DSDialog(
                    title: "토닥운 서비스를\n정말 탈퇴하시겠어요?",
                    message: "회원 탈퇴 시, 모든 서비스 이용이 불가해요.",
                    primaryAction: DSDialog.Action("확인") {
                        store.send(.accountSettings(.confirmWithdrawal))
                    },
                    secondaryAction: DSDialog.Action("취소") {
                        store.send(.accountSettings(.confirmationPresented(false)))
                    }
                )
            }
    }

    private static let notice = """
    토닥운 탈퇴 시, 사주 결과·토닥이 대화 내역·오늘의 운세 히스토리·월간 리포트 등 서비스 이용 데이터는 즉시 삭제되며 복구가 불가합니다.

    탈퇴 후 90일간은 동일한 SNS 계정(구글/애플/카카오)으로 재가입이 제한되며, 90일 경과 후 재가입 시에도 이전 계정 정보는 복구되지 않습니다.

    탈퇴 사유는 비식별화되어 서비스 개선 목적으로만 활용됩니다.
    """
}
