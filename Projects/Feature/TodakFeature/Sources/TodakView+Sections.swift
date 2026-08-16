import DesignSystem
import Foundation
import SwiftUI

extension TodakView {
    var historyScreen: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                DSHeaderSub(
                    title: "대화 히스토리",
                    leftItem: DSHeaderActionItem(identifier: "back", icon: .chevronLeftPlain) {
                        store.send(.historyBackButtonTapped)
                    }
                )

                if store.isLoadingHistory && store.conversations.isEmpty {
                    ProgressView()
                        .tint(DesignSystemAsset.Colors.primary600.swiftUIColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.conversations.isEmpty {
                    VStack(spacing: 8) {
                        Text("아직 대화가 없어요.")
                            .dsBody1Medium
                            .foregroundStyle(DesignSystemAsset.Colors.gray925.swiftUIColor)
                        Text("토닥이에게 궁금한 운세를 물어봐 주세요.")
                            .dsBody3Regular
                            .foregroundStyle(DesignSystemAsset.Colors.gray600.swiftUIColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    historyList
                }
            }

            TodakHistoryNewChatButton {
                store.send(.newChatButtonTapped)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            .zIndex(1)
        }
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.conversations) { conversation in
                    DSConversationHistoryList(
                        title: conversation.title,
                        time: relativeTime(conversation.lastMessageAt),
                        showsUnreadIndicator: conversation.unread,
                        onDelete: { store.send(.deleteButtonTapped(conversation.id)) }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { store.send(.conversationTapped(conversation.id)) }
                    .accessibilityAddTraits(.isButton)

                    Divider()
                        .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 88)
        }
    }

    var splashView: some View {
        GeometryReader { proxy in
            ZStack {
                DesignSystemAsset.Colors.primary50.swiftUIColor
                    .ignoresSafeArea()

                TodakFeatureAsset.todakSplash.swiftUIImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .ignoresSafeArea()

                splashTitle
                    .position(x: proxy.size.width / 2, y: 80)

                Text("토닥이에게\n궁금한 운세를 다 물어봐!")
                    .dsHeading4Bold
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DesignSystemAsset.Colors.black.swiftUIColor)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.78)
            }
        }
    }

    private var splashTitle: some View {
        HStack(spacing: 12) {
            Text("토닥운")
                .dsHeading4Bold
            Rectangle()
                .fill(DesignSystemAsset.Colors.gray400.swiftUIColor)
                .frame(width: 1, height: 20)
            Text("AI 토닥이")
                .dsHeading4Bold
        }
        .foregroundStyle(DesignSystemAsset.Colors.black.swiftUIColor)
    }

    func guideOverlay(category: TodakCategory) -> some View {
        let content = TodakGuideContent(category: category)

        return ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { store.send(.guideDismissed) }

            VStack(spacing: 0) {
                TodakCharacterImage(category: category)
                    .frame(width: 230, height: 230)

                VStack(spacing: 16) {
                    HStack(alignment: .top) {
                        Text(content.title)
                            .dsHeading4Bold
                            .foregroundStyle(DesignSystemAsset.Colors.black.swiftUIColor)
                            .frame(maxWidth: .infinity)

                        Button { store.send(.guideDismissed) } label: {
                            DSIcon(.closeLine, width: 20, height: 20)
                                .foregroundStyle(DesignSystemAsset.Colors.gray800.swiftUIColor)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("닫기")
                    }

                    Text(content.description)
                        .dsBody2Regular
                        .multilineTextAlignment(.center)
                        .foregroundStyle(DesignSystemAsset.Colors.gray800.swiftUIColor)
                }
                .padding(24)
                .background(DesignSystemAsset.Colors.white.swiftUIColor)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 20)
            }
        }
        .accessibilityAddTraits(.isModal)
    }

    var deleteConfirmationOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                DSDialog(
                    title: "이 대화를 삭제할까요?",
                    message: "삭제한 대화는 다시 확인할 수 없어요.",
                    primaryAction: DSDialog.Action("삭제") {
                        store.send(.deleteConfirmed)
                    },
                    secondaryAction: DSDialog.Action("취소") {
                        store.send(.deleteCancelled)
                    }
                )
            }
            .accessibilityAddTraits(.isModal)
    }

    private func relativeTime(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

private struct TodakHistoryNewChatButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                DSIcon(.chatAdd, width: 24, height: 24)
                Text("새 채팅")
                    .dsBody2Medium
            }
            .foregroundStyle(DesignSystemAsset.Colors.white.swiftUIColor)
            .padding(.horizontal, 20)
            .frame(height: 48)
            .background(DesignSystemAsset.Colors.primary700.swiftUIColor)
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .dsSurfaceButtonStyle(shape: .capsule)
        .accessibilityLabel("새 채팅")
    }
}

private struct TodakGuideContent {
    let title: String
    let description: String

    init(category: TodakCategory) {
        switch category {
        case .relationship:
            title = "관계운을 알려줄게!"
            description = "친구, 가족, 동료 등 고민되는 게 있으면 전부 나한테 물어봐."
        case .love:
            title = "연애운을 알려줄게!"
            description = "짝사랑, 썸, 연애 등 남한테 말하지 못하는 비밀을 나한테 털어놔."
        case .achievement:
            title = "성취운을 알려줄게!"
            description = "커리어, 학업, 목표 등 궁금한 점이나 고민은 전부 나한테 물어봐."
        case .money:
            title = "금전운을 알려줄게!"
            description = "수입, 지출, 재테크 등 돈의 흐름에 대해서 나한테 물어봐."
        case .health:
            title = "건강운을 알려줄게!"
            description = "컨디션, 습관, 마음가짐 등 요즘 신경 쓰이는 걸 나한테 말해봐."
        case .other:
            title = ""
            description = ""
        }
    }
}

struct TodakCharacterImage: View {
    let category: TodakCategory?
    let preservesAspectRatio: Bool

    init(category: TodakCategory?, preservesAspectRatio: Bool = true) {
        self.category = category
        self.preservesAspectRatio = preservesAspectRatio
    }

    @ViewBuilder
    var body: some View {
        if preservesAspectRatio {
            image
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        } else {
            image
                .resizable()
                .accessibilityHidden(true)
        }
    }

    private var image: Image {
        switch category {
        case .relationship:
            TodakFeatureAsset.todakRelationship.swiftUIImage
        case .love:
            TodakFeatureAsset.todakLove.swiftUIImage
        case .achievement:
            TodakFeatureAsset.todakAchievement.swiftUIImage
        case .money:
            TodakFeatureAsset.todakMoney.swiftUIImage
        case .health:
            TodakFeatureAsset.todakHealth.swiftUIImage
        case .other:
            TodakFeatureAsset.todakOther.swiftUIImage
        case nil:
            TodakFeatureAsset.todakDefault.swiftUIImage
        }
    }
}

struct TodakChatAvatar: View {
    let category: TodakCategory?

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 243 / 255, green: 246 / 255, blue: 1),
                            DesignSystemAsset.Colors.gray50.swiftUIColor
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            TodakCharacterImage(category: category, preservesAspectRatio: false)
//                .frame(width: 81, height: 74)
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
