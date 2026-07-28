import SwiftUI
struct DSWheelPickerColumnView: View {
    fileprivate struct Position: Hashable {
        let value: Int
        let cycle: Int
    }

    fileprivate struct DisplayItem: Identifiable {
        let item: DSWheelPickerItem
        let position: Position

        // swiftlint:disable:next identifier_name
        var id: Position {
            position
        }
    }

    let items: [DSWheelPickerItem]
    @Binding var selection: Int
    let accessibilityLabel: String
    let viewportHeight: CGFloat
    let rowHeight: CGFloat
    let selectedFontStyle: FontStyle
    let adjacentFontStyle: FontStyle
    let outerFontStyle: FontStyle
    let selectedForegroundAsset: DesignSystemColors
    let adjacentForegroundAsset: DesignSystemColors
    let outerForegroundAsset: DesignSystemColors
    let allowsDirectInput: Bool
    let maximumInputDigits: Int?
    let inputColumnIndex: Int?
    @Binding var activeInputColumnIndex: Int?
    let isCircular: Bool

    @State private var scrollPosition: Position?
    @State private var isEditing = false
    @State private var draftInput = ""
    @FocusState private var isInputFocused: Bool

    private var verticalInset: CGFloat {
        max(0, (viewportHeight - rowHeight) / 2)
    }

    private var selectedItem: DSWheelPickerItem? {
        items.first { $0.value == selection }
    }

    private var displayItems: [DisplayItem] {
        let cycles = isCircular && items.count > 1 ? Array(0...2) : [0]

        return cycles.flatMap { cycle in
            items.map {
                DisplayItem(
                    item: $0,
                    position: Position(value: $0.value, cycle: cycle)
                )
            }
        }
    }

    private var preferredCycle: Int {
        isCircular && items.count > 1 ? 1 : 0
    }

    var body: some View {
        ZStack {
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(displayItems) { displayItem in
                            row(displayItem)
                                .frame(maxWidth: .infinity)
                                .frame(height: rowHeight)
                                .contentShape(Rectangle())
                                .id(displayItem.id)
                                .onTapGesture {
                                    handleTap(displayItem)
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .safeAreaPadding(.vertical, verticalInset)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollPosition, anchor: .center)
                .scrollDisabled(isEditing)
                .scrollDismissesKeyboard(.immediately)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { _ in
                            activeInputColumnIndex = nil
                        }
                )
                .clipped()
                .onChange(of: items) { _, _ in
                    normalizeSelection(animated: false, using: scrollProxy)
                }
                .onChange(of: selection) { _, newValue in
                    guard scrollPosition?.value != newValue else { return }
                    normalizeSelection(animated: true, using: scrollProxy)
                }
            }

            if isEditing {
                TextField("", text: $draftInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .dsFont(selectedFontStyle)
                    .foregroundStyle(selectedForegroundAsset.swiftUIColor)
                    .focused($isInputFocused)
                    .frame(maxWidth: .infinity)
                    .frame(height: rowHeight)
                    .onChange(of: draftInput) { _, newValue in
                        handleInputChange(newValue)
                    }
            }
        }
        .accessibilityElement(children: isEditing ? .contain : .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(selectedItem?.title ?? "")
        .accessibilityAdjustableAction(adjustSelection)
        .onAppear {
            normalizeSelection(animated: false)
        }
        .onChange(of: scrollPosition) { _, newValue in
            guard let newValue else { return }

            if activeInputColumnIndex != inputColumnIndex {
                activeInputColumnIndex = nil
            }

            if newValue.value != selection {
                selection = newValue.value
            }

            recenterCircularPositionIfNeeded(newValue)
        }
        .onChange(of: isInputFocused) { wasFocused, isFocused in
            if wasFocused, !isFocused, isEditing {
                commitInput()
            }
        }
        .onChange(of: activeInputColumnIndex) { _, activeColumnIndex in
            if isEditing, activeColumnIndex != inputColumnIndex {
                commitInput()
            }
        }
        .onDisappear {
            if isEditing {
                commitInput()
            }
        }
        .dsDebugDetailGeometry("DSWheelPicker.Column.\(accessibilityLabel)")
    }
}

private extension DSWheelPickerColumnView {
    func handleInputChange(_ input: String) {
        guard let maximumInputDigits else { return }

        let normalizedInput = DSWheelPickerDirectInputPolicy.normalizedDigits(
            input,
            maximumDigits: maximumInputDigits
        )

        if draftInput != normalizedInput {
            draftInput = normalizedInput
            return
        }

        if DSWheelPickerDirectInputPolicy.shouldCommit(
            normalizedInput,
            maximumDigits: maximumInputDigits
        ) {
            Task { @MainActor in
                guard isEditing, draftInput == normalizedInput else { return }
                commitInput()
            }
        }
    }

    func commitInput() {
        guard isEditing else { return }

        let proposedValue = Int(draftInput)
        let resolvedValue = proposedValue.flatMap {
            DSWheelPickerSelectionResolver.nearestValue(
                to: $0,
                in: items
            )
        }

        isEditing = false
        isInputFocused = false

        if activeInputColumnIndex == inputColumnIndex {
            activeInputColumnIndex = nil
        }

        if let resolvedValue {
            select(resolvedValue, animated: true)
        } else {
            normalizeSelection(animated: true)
        }
    }
}

private extension DSWheelPickerColumnView {
    @ViewBuilder
    func row(_ displayItem: DisplayItem) -> some View {
        let style = rowStyle(for: displayItem)

        if isEditing, displayItem.position == scrollPosition {
            Color.clear
        } else {
            Text(displayItem.item.title)
                .dsFont(style.fontStyle)
                .foregroundStyle(style.foregroundAsset.swiftUIColor)
                .contentTransition(.interpolate)
                .animation(DSWheelPickerRowVisualStyle.transition, value: style.emphasis)
        }
    }

    private func rowStyle(
        for displayItem: DisplayItem
    ) -> DSWheelPickerRowVisualStyle {
        guard
            let activePosition = scrollPosition
                ?? position(for: selection, cycle: preferredCycle),
            let selectedIndex = displayItems.firstIndex(where: {
                $0.position == activePosition
            }),
            let itemIndex = displayItems.firstIndex(where: {
                $0.position == displayItem.position
            })
        else {
            return .outer(fontStyle: outerFontStyle, foregroundAsset: outerForegroundAsset)
        }

        switch abs(selectedIndex - itemIndex) {
        case 0:
            return .selected(fontStyle: selectedFontStyle, foregroundAsset: selectedForegroundAsset)
        case 1:
            return .adjacent(fontStyle: adjacentFontStyle, foregroundAsset: adjacentForegroundAsset)
        default:
            return .outer(fontStyle: outerFontStyle, foregroundAsset: outerForegroundAsset)
        }
    }

    func handleTap(_ displayItem: DisplayItem) {
        if allowsDirectInput, displayItem.position == scrollPosition {
            if let activeInputColumnIndex, activeInputColumnIndex != inputColumnIndex {
                self.activeInputColumnIndex = nil
                return
            }

            activeInputColumnIndex = inputColumnIndex
            draftInput = ""
            isEditing = true

            Task { @MainActor in
                guard isEditing, activeInputColumnIndex == inputColumnIndex else {
                    return
                }
                isInputFocused = true
            }
            return
        }

        if isEditing {
            commitInput()
        } else {
            activeInputColumnIndex = nil
        }

        select(
            displayItem.item.value,
            at: displayItem.position,
            animated: true
        )
    }

    func normalizeSelection(animated: Bool, using scrollProxy: ScrollViewProxy? = nil) {
        guard
            let resolvedValue = DSWheelPickerSelectionResolver.nearestValue(
                to: selection,
                in: items
            )
        else {
            scrollPosition = nil
            return
        }

        if selection != resolvedValue {
            selection = resolvedValue
        }

        guard let position = position(for: resolvedValue, cycle: preferredCycle) else {
            scrollPosition = nil
            return
        }

        setScrollPosition(position, animated: animated, using: scrollProxy)
    }

    func select(
        _ value: Int,
        at position: Position? = nil,
        animated: Bool
    ) {
        guard items.contains(where: { $0.value == value }) else { return }

        if selection != value {
            selection = value
            return
        }

        guard let targetPosition = position
            ?? self.position(for: value, cycle: preferredCycle)
        else {
            return
        }

        setScrollPosition(targetPosition, animated: animated)
    }

    func setScrollPosition(
        _ position: Position, animated: Bool, using scrollProxy: ScrollViewProxy? = nil
    ) {
        let updatePosition = {
            scrollPosition = position
            scrollProxy?.scrollTo(position, anchor: .center)
        }

        if animated {
            withAnimation(.snappy) {
                updatePosition()
            }
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction, updatePosition)
        }
    }

    func position(for value: Int, cycle: Int) -> Position? {
        guard items.contains(where: { $0.value == value }) else { return nil }
        return Position(value: value, cycle: cycle)
    }

    func recenterCircularPositionIfNeeded(_ position: Position) {
        guard isCircular, items.count > 1, position.cycle != preferredCycle else {
            return
        }

        Task { @MainActor in
            guard scrollPosition == position else { return }
            scrollPosition = self.position(
                for: position.value,
                cycle: preferredCycle
            )
        }
    }

    func adjustSelection(_ direction: AccessibilityAdjustmentDirection) {
        guard
            let currentIndex = items.firstIndex(where: { $0.value == selection })
        else {
            normalizeSelection(animated: true)
            return
        }

        let targetIndex: Int

        switch direction {
        case .increment:
            if isCircular, currentIndex == items.index(before: items.endIndex) {
                targetIndex = items.startIndex
            } else {
                targetIndex = min(items.index(before: items.endIndex), currentIndex + 1)
            }
        case .decrement:
            if isCircular, currentIndex == items.startIndex {
                targetIndex = items.index(before: items.endIndex)
            } else {
                targetIndex = max(items.startIndex, currentIndex - 1)
            }
        @unknown default:
            return
        }

        select(items[targetIndex].value, animated: true)
    }
}
