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
        }
    }
}
