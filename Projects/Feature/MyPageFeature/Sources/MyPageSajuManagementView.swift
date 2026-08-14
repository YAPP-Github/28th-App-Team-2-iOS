import ComposableArchitecture
import DesignSystem
import Model
import SwiftUI

// swiftlint:disable file_length
struct MyPageSajuManagementView: View {
    @Bindable private var store: StoreOf<MyPageFeature>
    @State private var menuButtonFrames: [String: CGRect] = [:]

    init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    var body: some View {
        if store.sajuManagement?.form != nil {
            MyPagePartnerFormView(store: store)
        } else {
            managementContent
        }
    }

    private var managementContent: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                DSHeaderSub(
                    title: "사주 정보 관리",
                    leftItem: DSHeaderActionItem(
                        identifier: "back",
                        icon: .chevronLeftNarrow,
                        action: { store.send(.sajuManagementDismissButtonTapped) }
                    )
                )

                if store.sajuManagement?.isLoading == true {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            sectionTitle
                            partnerList
                            addCard
                                .padding(.top, 12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        .padding(.bottom, isFull ? 72 : 24)
                    }
                    .coordinateSpace(name: "sajuManagementScroll")
                    .overlay(alignment: .topLeading) {
                        if let expandedMenuLinkID = store.sajuManagement?.expandedMenuLinkID,
                           let menuButtonFrame = menuButtonFrames[expandedMenuLinkID] {
                            partnerMenuPopover(for: expandedMenuLinkID, at: menuButtonFrame)
                        }
                    }
                    .clipped()
                }
            }

            if let message = store.sajuManagement?.toastMessage {
                DSToast(message) { store.send(.partnerToastDismissed) }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onPreferenceChange(PartnerMenuButtonFrameKey.self) { menuButtonFrames = $0 }
        .background(Color.ds.white)
        .task { store.send(.sajuManagementTask) }
    }

    private var sectionTitle: some View {
        HStack(spacing: 8) {
            Text("등록된 사주 정보")
                .dsBody1Bold
                .foregroundStyle(Color.ds.gray975)
            Text("\(store.sajuManagement?.partners.count ?? 0)")
                .dsBody3Medium
                .foregroundStyle(Color.ds.coolGray600)
                .frame(width: 20, height: 20)
                .background(Color.ds.coolGray300, in: Capsule())
            Spacer(minLength: 0)
        }
        .frame(height: 26)
        .padding(.bottom, 17)
    }

    @ViewBuilder
    private var partnerList: some View {
        let partners = store.sajuManagement?.partners ?? []
        if partners.isEmpty {
            Text("등록된 상대방 사주 정보가 없어요.")
                .dsBody3Medium
                .foregroundStyle(Color.ds.coolGray600)
                .frame(maxWidth: .infinity, minHeight: 85)
                .background(Color.ds.coolGray50, in: RoundedRectangle(cornerRadius: 12))
        } else {
            LazyVStack(spacing: 12) {
                ForEach(partners) { partner in
                    MyPagePartnerCard(
                        partner: partner,
                        onMenu: { store.send(.partnerMenuButtonTapped(partner.linkID)) }
                    )
                }
            }
        }
    }

    private var addCard: some View {
        Button { store.send(.partnerAddButtonTapped) } label: {
            VStack(spacing: 16) {
                DSIcon(.addUser, width: 20, height: 20)
                    .foregroundStyle(Color.ds.gray975)
                    .frame(width: 48, height: 48)
                    .background(Color.ds.black.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
                Text("사주 정보 추가(최대 10명)")
                    .dsCaption2Regular
                    .foregroundStyle(Color.ds.gray975)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 128)
            .background(Color.ds.coolGray50, in: RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel("사주 정보 추가")
    }

    private var isFull: Bool { (store.sajuManagement?.partners.count ?? 0) >= 10 }

    private func partnerMenuPopover(for linkID: String, at frame: CGRect) -> some View {
        DSPopover(items: [
            DSPopoverItem(
                identifier: "edit",
                title: "수정하기",
                action: { store.send(.partnerEditButtonTapped(linkID)) }
            ),
            DSPopoverItem(
                identifier: "delete",
                title: "삭제하기",
                action: { store.send(.partnerDeleteButtonTapped(linkID)) }
            )
        ])
        .offset(x: frame.maxX - 108, y: frame.maxY + 12)
    }
}

private struct MyPagePartnerCard: View {
    let partner: MyPagePartnerSaju
    let onMenu: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(partner.name).dsBody1Bold
                    Text("∙").dsBody2Regular
                    Text(partner.genderText).dsBody2Regular
                    DSBadge(partner.relationshipLabel, variant: .gray)
                }
                .foregroundStyle(Color.ds.gray975)

                HStack(spacing: 8) {
                    Text(partner.birthDateCalendarText)
                    if let birthTimeText = partner.birthTimeText {
                        Text("∙")
                        Text(birthTimeText)
                    }
                }
                .dsBody3Medium
                .foregroundStyle(Color.ds.coolGray700)
            }

            Spacer(minLength: 0)
            Button(action: onMenu) {
                DSIcon(.moreLine, width: 20, height: 20)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.ds.gray400)
            }
            .buttonStyle(.plain)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: PartnerMenuButtonFrameKey.self,
                        value: [partner.linkID: proxy.frame(in: .named("sajuManagementScroll"))]
                    )
                }
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 85, alignment: .topLeading)
        .background(Color.ds.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ds.gray200, lineWidth: 1))
    }
}

private struct PartnerMenuButtonFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, latest in latest })
    }
}

private struct MyPagePartnerFormView: View {
    @Bindable private var store: StoreOf<MyPageFeature>
    @FocusState private var isNameFocused: Bool

    init(store: StoreOf<MyPageFeature>) { self.store = store }

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: form?.editingLinkID == nil ? "상대방 정보 입력" : "상대방 정보 수정",
                leftItem: DSHeaderActionItem(
                    identifier: "back",
                    icon: .chevronLeftNarrow,
                    action: { store.send(.partnerFormDismissButtonTapped) }
                )
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    DSEnterName(
                        text: nameBinding,
                        validationState: nameValidationState,
                        isFocused: $isNameFocused
                    )
                    DSSajuBasicFieldsView(
                        gender: genderBinding,
                        calendarType: calendarBinding,
                        birthDate: birthDateBinding,
                        birthTime: birthTimeBinding,
                        isBirthTimeUnknown: birthTimeUnknownBinding,
                        birthDateValidationMessage: BirthDatePolicy.validateNotInFuture(for: form?.birthDate, asOf: Date()),
                        spacing: 40
                    )
                    relationshipField
                    DSPrimaryLargeButton(form?.isSaving == true ? "저장 중…" : "저장하기") {
                        store.send(.partnerSaveButtonTapped)
                    }
                    .disabled(form?.isValid != true || form?.isSaving == true)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
        .background(Color.ds.white)
    }

    private var relationshipField: some View {
        DSSelectRelationship(selection: relationshipBinding)
    }

    private var form: MyPageFeature.PartnerFormState? { store.sajuManagement?.form }
    private var nameValidationState: DSTextFieldValidationState {
        form?.nameValidationMessage.map { .error(message: $0) } ?? .none
    }
    private var nameBinding: Binding<String> {
        Binding(get: { form?.name ?? "" }, set: { store.send(.partnerNameChanged($0)) })
    }

    private var genderBinding: Binding<Gender?> {
        Binding(get: { form?.gender }, set: { store.send(.partnerGenderChanged($0)) })
    }

    private var calendarBinding: Binding<BirthDateCalendar?> {
        Binding(get: { form?.calendar }, set: { store.send(.partnerCalendarChanged($0)) })
    }

    private var birthDateBinding: Binding<BirthDate?> {
        Binding(get: { form?.birthDate }, set: { store.send(.partnerBirthDateChanged($0)) })
    }

    private var birthTimeBinding: Binding<BirthTimePeriod?> {
        Binding(get: { form?.birthTime }, set: { store.send(.partnerBirthTimeChanged($0)) })
    }

    private var birthTimeUnknownBinding: Binding<Bool> {
        Binding(
            get: { form?.isBirthTimeUnknown ?? false },
            set: { store.send(.partnerBirthTimeUnknownChanged($0)) }
        )
    }

    private var relationshipBinding: Binding<Relationship?> {
        Binding(
            get: { form?.relationship },
            set: {
                guard let relationship = $0 else { return }
                store.send(.partnerRelationshipChanged(relationship))
            }
        )
    }
}

#Preview("사주 정보 관리 - 최대 인원") {
    var state = MyPageFeature.State()
    var management = MyPageFeature.SajuManagementState()
    management.isLoading = false
    management.partners = (1...10).map { index in
        MyPagePartnerSaju(
            linkID: "preview-link-\(index)",
            relationshipCode: index.isMultiple(of: 2) ? "FRIEND" : "LOVER",
            relationshipLabel: index.isMultiple(of: 2) ? "친구" : "연인",
            name: "상대방\(index)",
            gender: index.isMultiple(of: 2) ? "MALE" : "FEMALE",
            birthDate: "199\(index % 10)-0\(index % 9 + 1)-15",
            calendarType: index.isMultiple(of: 2) ? "LUNAR" : "SOLAR",
            birthTime: "09:30",
            isTimeUnknown: index.isMultiple(of: 3)
        )
    }
    state.sajuManagement = management

    return MyPageSajuManagementView(
        store: Store(initialState: state) {
            MyPageFeature()
        }
    )
}
