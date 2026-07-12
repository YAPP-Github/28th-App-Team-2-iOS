import SwiftUI

// MARK: - Core Checkbox Component
public struct DSCheckbox: View {
    public enum Layout {
        public static let size: CGFloat = 20
        public static let cornerRadius: CGFloat = 6
        public static let borderWidth: CGFloat = 1
        public static let iconSize: CGFloat = 16
    }
    
    @Binding private var isOn: Bool
    
    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }
    
    public var body: some View {
        Toggle(isOn: $isOn) {
            EmptyView()
        }
        .toggleStyle(DSCheckboxStyle())
    }
}
