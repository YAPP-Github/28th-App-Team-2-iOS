import SwiftUI
import DesignSystem

struct BottomNavigationPlaygroundView: View {
    @State private var selectedItem: DSBottomNavigationItem = .fortune
    @State private var isDarkBackground = false

    var body: some View {
        VStack(spacing: 0) {
            DSPlaygroundPreviewCard(
                title: String(describing: DSBottomNavigation.self),
                isDarkBackground: $isDarkBackground
            ) {
                DSBottomNavigation(selectedItem: $selectedItem)
            }

            Form {
                Section(header: Text("Interactive State")) {
                    Picker("Selected Item", selection: $selectedItem) {
                        ForEach(DSBottomNavigationItem.allCases, id: \.self) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Figma Specification Check")) {
                    let specification = DSBottomNavigation.specification
                    let itemSpecification = DSBottomNavigation.itemSpecification(
                        for: selectedItem,
                        isSelected: true
                    )
                    let unselectedItemSpecification = DSBottomNavigation.itemSpecification(
                        for: selectedItem,
                        isSelected: false
                    )

                    DSSpecificationRow(title: "Height", value: "\(specification.height.ptDescription)")
                    DSSpecificationRow(
                        title: "Horizontal Padding",
                        value: "\(specification.contentHorizontalPadding.ptDescription)"
                    )
                    DSSpecificationRow(
                        title: "Vertical Padding",
                        value: "\(specification.contentVerticalPadding.ptDescription)"
                    )
                    DSSpecificationRow(
                        title: "Item Top Padding",
                        value: "\(specification.itemTopPadding.ptDescription)"
                    )
                    DSSpecificationRow(
                        title: "Shape",
                        value: "\(specification.shape.specName)"
                    )
                    DSSpecificationRow(title: "Selected Icon", value: itemSpecification.iconAsset.name)
                    DSSpecificationRow(title: "Selected Text Font", value: itemSpecification.titleFont.specName)
                    DSSpecificationRow(
                        title: "Selected Text Color",
                        value: itemSpecification.titleColor.specDescription
                    )
                    DSSpecificationRow(title: "Unselected Text Font", value: unselectedItemSpecification.titleFont.specName)
                    DSSpecificationRow(
                        title: "Unselected Text Color",
                        value: unselectedItemSpecification.titleColor.specDescription
                    )
                    DSSpecificationRow(
                        title: "Shadow Blur",
                        value: "\(specification.shadowRadius.ptDescription)"
                    )
                }
            }
        }
        .navigationTitle("DSBottomNavigation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BottomNavigationPlaygroundView()
    }
}
