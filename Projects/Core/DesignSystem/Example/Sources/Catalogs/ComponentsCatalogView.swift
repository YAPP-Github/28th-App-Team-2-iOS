import SwiftUI
import DesignSystem

// MARK: - Components Catalog List
struct ComponentsCatalogView: View {
    var body: some View {
        List {
            NavigationLink(destination: ButtonPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.and.hand.point.up.left.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Button")
                            .font(.headline)
                        Text("Primary, Secondary / Large, Medium, Small 규격 버튼")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: ChipPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chip")
                            .font(.headline)
                        Text("Selected, Unselected 상태 변경을 제어하는 칩 태그")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: BadgePlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "app.badge.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Badge")
                            .font(.headline)
                        Text("상태나 카테고리를 표시하는 정적 라벨 뱃지")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: CheckboxPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Checkbox")
                            .font(.headline)
                        Text("단일 선택 여부를 토글하는 체크박스 컴포넌트")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: DividerPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "minus")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Divider")
                            .font(.headline)
                        Text("1pt, 10pt 두께로 콘텐츠 영역을 구분하는 디바이더")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: TogglePlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "switch.2")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Toggle")
                            .font(.headline)
                        Text("On/Off 상태를 제어하는 스위치 컴포넌트")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: TextFieldPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "character.cursor.ibeam")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("TextField")
                            .font(.headline)
                        Text("텍스트 입력을 위한 인풋 컴포넌트")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: ProgressBarPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress Bar")
                            .font(.headline)
                        Text("진행 상태를 나타내는 게이지 컴포넌트")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: TabPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "capsule.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tab")
                            .font(.headline)
                        Text("화면 간 이동을 위한 상단 탭 버튼")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: SelectBoxPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.rectangle.stack.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("SelectBox")
                            .font(.headline)
                        Text("선택 여부를 on/off 상태로 표현하는 선택 상자")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: TooltipPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tooltip")
                            .font(.headline)
                        Text("짧은 안내 메시지를 화살표와 함께 표시하는 툴팁")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            NavigationLink(destination: TodakHeaderPlaygroundView()) {
                HStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .foregroundColor(.ds.primary600)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Todak Header")
                            .font(.headline)
                        Text("토닥이 채팅 화면의 상단 헤더와 무료 채팅 진행 상태")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
