import SwiftUI
struct DSWheelPickerColumnView: View {
    let items: [DSWheelPickerItem]
    @Binding var selection: Int
    let accessibilityLabel: String
    let rendering: DSWheelPickerRenderingConfiguration
    let directInput: DSWheelPickerDirectInputConfiguration?
    @Binding var activeInputColumnIndex: Int?
    let isCircular: Bool

    @State private var scrollPosition: DSWheelPickerPosition?
    @State private var isEditing = false
    @State private var draftInput = ""
    @FocusState private var isInputFocused: Bool

    init(
        items: [DSWheelPickerItem],
        selection: Binding<Int>,
        accessibilityLabel: String,
        rendering: DSWheelPickerRenderingConfiguration,
        directInput: DSWheelPickerDirectInputConfiguration?,
        isCircular: Bool
    ) {
        self.items = items
        self._selection = selection
        self.accessibilityLabel = accessibilityLabel
        self.rendering = rendering
        self.directInput = directInput
        self._activeInputColumnIndex = directInput?.activeColumnIndex ?? .constant(nil)
        self.isCircular = isCircular
    }

    private var verticalInset: CGFloat {
        max(0, (rendering.viewportHeight - rendering.rowHeight) / 2)
    }

    private var maximumInputDigits: Int? {
        directInput?.maximumDigits
    }

    private var inputColumnIndex: Int? {
        directInput?.columnIndex
    }

    private var nextInputColumnIndex: Int? {
        directInput?.nextColumnIndex
    }

    private var selectedItem: DSWheelPickerItem? {
        items.first { $0.value == selection }
    }

    private var displayItems: [DSWheelPickerDisplayItem] {
        DSWheelPickerDisplayItem.make(items: items, isCircular: isCircular)
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
                                .frame(height: rendering.rowHeight)
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
                .task(id: items) {
                    await Task.yield()
                    guard !Task.isCancelled else { return }
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
                    .dsFont(rendering.selectedFontStyle)
                    .foregroundStyle(rendering.selectedForegroundAsset.swiftUIColor)
                    .focused($isInputFocused)
                    .frame(maxWidth: .infinity)
                    .frame(height: rendering.rowHeight)
                    .onChange(of: draftInput) { _, newValue in
                        handleInputChange(newValue)
                    }
                    .task {
                        await Task.yield()
                        guard
                            isEditing,
                            activeInputColumnIndex == inputColumnIndex
                        else {
                            return
                        }
                        isInputFocused = true
                    }
            }
        }
        .accessibilityElement(children: isEditing ? .contain : .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(selectedItem?.title ?? "")
        .accessibilityAdjustableAction(adjustSelection)
        .onChange(of: scrollPosition) { _, newValue in
            guard let newValue else { return }

            if newValue.value != selection {
                selection = newValue.value
            }

            recenterCircularPositionIfNeeded(newValue)
        }
        .onChange(of: isInputFocused) { wasFocused, isFocused in
            if wasFocused, !isFocused, isEditing {
                Task { @MainActor in
                    await Task.yield()
                    guard !isInputFocused, isEditing else { return }
                    commitInput()
                }
            }
        }
        .onChange(of: activeInputColumnIndex) { _, activeColumnIndex in
            if activeColumnIndex == inputColumnIndex, !isEditing {
                beginInput()
            } else if isEditing, activeColumnIndex != inputColumnIndex {
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
                commitInput(activating: nextInputColumnIndex)
            }
        }
    }

    func beginInput() {
        guard directInput != nil, !isEditing else { return }

        draftInput = ""
        isEditing = true
    }

    func commitInput(activating nextColumnIndex: Int? = nil) {
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

        if let resolvedValue {
            select(resolvedValue, animated: true)
        } else {
            normalizeSelection(animated: true)
        }

        if activeInputColumnIndex == inputColumnIndex {
            activeInputColumnIndex = nextColumnIndex
        }
    }
}

private extension DSWheelPickerColumnView {
    @ViewBuilder
    func row(_ displayItem: DSWheelPickerDisplayItem) -> some View {
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
        for displayItem: DSWheelPickerDisplayItem
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
            return .outer(
                fontStyle: rendering.outerFontStyle,
                foregroundAsset: rendering.outerForegroundAsset
            )
        }

        switch abs(selectedIndex - itemIndex) {
        case 0:
            return .selected(
                fontStyle: rendering.selectedFontStyle,
                foregroundAsset: rendering.selectedForegroundAsset
            )
        case 1:
            return .adjacent(
                fontStyle: rendering.adjacentFontStyle,
                foregroundAsset: rendering.adjacentForegroundAsset
            )
        default:
            return .outer(
                fontStyle: rendering.outerFontStyle,
                foregroundAsset: rendering.outerForegroundAsset
            )
        }
    }

    func handleTap(_ displayItem: DSWheelPickerDisplayItem) {
        if directInput != nil, displayItem.position == scrollPosition {
            if activeInputColumnIndex == inputColumnIndex {
                beginInput()
            } else {
                activeInputColumnIndex = inputColumnIndex
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
        at position: DSWheelPickerPosition? = nil,
        animated: Bool
    ) {
        guard items.contains(where: { $0.value == value }) else { return }

        guard let targetPosition = position
            ?? self.position(for: value, cycle: preferredCycle)
        else {
            return
        }

        if selection != value {
            selection = value
        }

        setScrollPosition(targetPosition, animated: animated)
    }

    func setScrollPosition(
        _ position: DSWheelPickerPosition,
        animated: Bool,
        using scrollProxy: ScrollViewProxy? = nil
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

    func position(for value: Int, cycle: Int) -> DSWheelPickerPosition? {
        guard items.contains(where: { $0.value == value }) else { return nil }
        return DSWheelPickerPosition(value: value, cycle: cycle)
    }

    func recenterCircularPositionIfNeeded(_ position: DSWheelPickerPosition) {
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
        guard let adjustedValue = DSWheelPickerSelectionResolver.adjustedValue(
            from: selection,
            direction: direction,
            in: items,
            isCircular: isCircular
        ) else {
            normalizeSelection(animated: true)
            return
        }
        select(adjustedValue, animated: true)
    }
}
