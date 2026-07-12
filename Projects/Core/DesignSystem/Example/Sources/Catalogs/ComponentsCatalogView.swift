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
        }
    }
}
