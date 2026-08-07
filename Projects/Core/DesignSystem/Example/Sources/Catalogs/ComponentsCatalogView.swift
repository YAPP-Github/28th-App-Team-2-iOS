import SwiftUI
import DesignSystem

// MARK: - Components Catalog List
struct ComponentsCatalogView: View {
    var body: some View {
        List {
            catalogLink(
                destination: ButtonPlaygroundView(),
                systemImage: "rectangle.and.hand.point.up.left.fill",
                title: "Button",
                subtitle: "Primary, Secondary / Large, Medium, Small 규격 버튼"
            )
            catalogLink(
                destination: ChipPlaygroundView(),
                systemImage: "tag.fill",
                title: "Chip",
                subtitle: "Selected, Unselected 상태 변경을 제어하는 칩 태그"
            )
            catalogLink(
                destination: BadgePlaygroundView(),
                systemImage: "app.badge.fill",
                title: "Badge",
                subtitle: "상태나 카테고리를 표시하는 정적 라벨 뱃지"
            )
            catalogLink(
                destination: CheckboxPlaygroundView(),
                systemImage: "checkmark.square.fill",
                title: "Checkbox",
                subtitle: "단일 선택 여부를 토글하는 체크박스 컴포넌트"
            )
            catalogLink(
                destination: DividerPlaygroundView(),
                systemImage: "minus",
                title: "Divider",
                subtitle: "1pt, 10pt 두께로 콘텐츠 영역을 구분하는 디바이더"
            )
            catalogLink(
                destination: TogglePlaygroundView(),
                systemImage: "switch.2",
                title: "Toggle",
                subtitle: "On/Off 상태를 제어하는 스위치 컴포넌트"
            )
            catalogLink(
                destination: TextFieldPlaygroundView(),
                systemImage: "character.cursor.ibeam",
                title: "TextField",
                subtitle: "텍스트 입력을 위한 인풋 컴포넌트"
            )
            catalogLink(
                destination: ProgressBarPlaygroundView(),
                systemImage: "chart.bar.fill",
                title: "Progress Bar",
                subtitle: "진행 상태를 나타내는 게이지 컴포넌트"
            )
            catalogLink(
                destination: TabPlaygroundView(),
                systemImage: "capsule.fill",
                title: "Tab",
                subtitle: "화면 간 이동을 위한 상단 탭 버튼"
            )
            catalogLink(
                destination: BottomNavigationPlaygroundView(),
                systemImage: "rectangle.bottomthird.inset.filled",
                title: "Bottom Navigation",
                subtitle: "선택 상태를 외부 Binding으로 제어하는 하단 네비게이션"
            )
            catalogLink(
                destination: SelectBoxPlaygroundView(),
                systemImage: "checkmark.rectangle.stack.fill",
                title: "SelectBox",
                subtitle: "선택 여부를 on/off 상태로 표현하는 선택 상자"
            )
            catalogLink(
                destination: SelectFieldPlaygroundView(),
                systemImage: "chevron.down.square.fill",
                title: "SelectField",
                subtitle: "선택 화면 진입과 선택값 삭제를 제공하는 필드 버튼"
            )
            catalogLink(
                destination: HeaderPlaygroundView(),
                systemImage: "rectangle.topthird.inset.filled",
                title: "Header",
                subtitle: "화면이 필요한 액션을 주입하는 Main, Sub 상단 헤더"
            )
            catalogLink(
                destination: TodakHeaderPlaygroundView(),
                systemImage: "bubble.left.and.text.bubble.right.fill",
                title: "Todak Header",
                subtitle: "AI 채팅 화면 상단에서 무료 채팅 횟수와 액션을 표시하는 헤더"
            )
            catalogLink(
                destination: TooltipPlaygroundView(),
                systemImage: "text.bubble.fill",
                title: "Tooltip",
                subtitle: "짧은 안내 메시지를 화살표와 함께 표시하는 툴팁"
            )
            catalogLink(
                destination: SingleWheelPickerPlaygroundView(),
                systemImage: "filemenu.and.selection",
                title: "Single WheelPicker",
                subtitle: "외부 선택 상태로 제어하는 단일 열 WheelPicker"
            )
            catalogLink(
                destination: MultiWheelPickerPlaygroundView(),
                systemImage: "rectangle.split.3x1",
                title: "Multi WheelPicker",
                subtitle: "시간 2열과 직접 입력 가능한 생년월일 3열 WheelPicker"
            )
            catalogLink(
                destination: WheelPickerPanelPlaygroundView(),
                systemImage: "rectangle.bottomhalf.inset.filled",
                title: "WheelPicker Panel",
                subtitle: "Custom overlay Sheet로 표시하는 Picker 패널"
            )
            catalogLink(
                destination: PopoverPlaygroundView(),
                systemImage: "rectangle.on.rectangle.angled",
                title: "Popover",
                subtitle: "제목과 선택 동작을 연결하는 팝오버"
            )
            catalogLink(
                destination: ToastPlaygroundView(),
                systemImage: "rectangle.bottomhalf.inset.filled",
                title: "Toast",
                subtitle: "Standard, Compact, Lucky Action 알림 컴포넌트"
            )
            catalogLink(
                destination: DialogPlaygroundView(),
                systemImage: "rectangle.center.inset.filled",
                title: "Dialog",
                subtitle: "본문과 보조 버튼을 선택적으로 제공하는 다이얼로그"
                destination: ChatTypeBoxPlaygroundView(),
                systemImage: "arrow.up.circle.fill",
                title: "Chat Type Box",
                subtitle: "질문 입력과 전송 동작을 제공하는 채팅 입력창"
            )
            catalogLink(
                destination: UserChatPlaygroundView(),
                systemImage: "bubble.right.fill",
                title: "User Chat",
                subtitle: "사용자 발화 내용을 우측 정렬로 표시하는 말풍선"
            )
            catalogLink(
                destination: TodakExampleQuestionPlaygroundView(),
                systemImage: "sparkles",
                title: "Todak Example Question",
                subtitle: "토닥이에게 보낼 예시 질문을 표시하는 말풍선"
            )
            catalogLink(
                destination: ConversationHistoryListPlaygroundView(),
                systemImage: "text.line.first.and.arrowtriangle.forward",
                title: "Conversation History List",
                subtitle: "대화 제목, 시간, 읽지 않은 상태와 삭제 동작을 표시하는 행"
            )
        }
    }

    private func catalogLink<Destination: View>(
        destination: Destination,
        systemImage: String,
        title: String,
        subtitle: String
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.ds.primary600)
                    .imageScale(.large)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.ds.gray600)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
