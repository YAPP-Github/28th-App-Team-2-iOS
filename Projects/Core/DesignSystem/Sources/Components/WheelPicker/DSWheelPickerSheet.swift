import SwiftUI
import UIKit

public extension View {
    func dsWheelPickerSheet<Content: View>(
        isPresented: Binding<Bool>,
        layout: DSWheelPickerPanelLayout,
        title: String,
        actionTitle: String = "저장",
        bottomSafeAreaSpacing: CGFloat? = nil,
        onSave: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            DSWheelPickerSheetModifier(
                isPresented: isPresented,
                layout: layout,
                title: title,
                actionTitle: actionTitle,
                bottomSafeAreaSpacing: bottomSafeAreaSpacing,
                onSave: onSave,
                sheetContent: content
            )
        )
    }
}

private struct DSWheelPickerSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var isHostPresented = false
    @State private var isPanelVisible = false
    @State private var isKeyboardPresented = false
    @State private var windowSafeAreaBottom: CGFloat = 0
    @GestureState(
        resetTransaction: Transaction(animation: .snappy)
    ) private var dragOffset: CGFloat = 0

    let layout: DSWheelPickerPanelLayout
    let title: String
    let actionTitle: String
    let bottomSafeAreaSpacing: CGFloat?
    let onSave: () -> Void
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .accessibilityHidden(isHostPresented)
            .fullScreenCover(isPresented: $isHostPresented) {
                presentation
                    .presentationBackground(.clear)
                    .task {
                        await Task.yield()
                        revealPanel()
                    }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillShowNotification
                )
            ) { _ in
                isKeyboardPresented = true
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillHideNotification
                )
            ) { _ in
                isKeyboardPresented = false
            }
            .onAppear {
                if isPresented {
                    presentHost()
                }
            }
            .onChange(of: isPresented) { _, shouldPresent in
                if shouldPresent {
                    presentHost()
                } else {
                    dismissPanel()
                }
            }
            .onChange(of: isHostPresented) { _, isPresented in
                if !isPresented {
                    isPanelVisible = false
                    isKeyboardPresented = false

                    if self.isPresented {
                        self.isPresented = false
                    }
                }
            }
    }

    private var presentation: some View {
        let specification = DSWheelPickerPanel.specification(layout: layout)

        let bottomSpacing = DSWheelPickerSheetBottomSpacingResolver.resolvedSpacing(
            defaultSpacing: specification.sheetBottomSpacing,
            keyboardSpacing: specification.keyboardSheetBottomSpacing,
            safeAreaBottom: windowSafeAreaBottom,
            safeAreaSpacing: bottomSafeAreaSpacing,
            isKeyboardPresented: isKeyboardPresented
        )

        return ZStack(alignment: .bottom) {
            specification.dimmingAsset.swiftUIColor
                .contentShape(Rectangle())
                .onTapGesture {
                    isPresented = false
                }
                .accessibilityLabel("닫기")
                .accessibilityAddTraits(.isButton)

            if isPanelVisible {
                DSWheelPickerPanel(
                    layout: layout,
                    title: title,
                    actionTitle: actionTitle,
                    onSave: onSave,
                    content: sheetContent
                )
                .offset(y: max(0, dragOffset))
                .overlay(alignment: .top) {
                    Color.clear
                        .frame(height: dragHandleHeight(specification))
                        .contentShape(Rectangle())
                        .gesture(dismissGesture)
                        .accessibilityHidden(true)
                }
                .padding(.bottom, bottomSpacing)
                .transition(.move(edge: .bottom))
                .accessibilityAddTraits(.isModal)
            }
        }
        .background {
            DSWheelPickerWindowSafeAreaReader(bottomInset: $windowSafeAreaBottom)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea(.container)
    }

    private func presentHost() {
        if isHostPresented {
            revealPanel()
            return
        }

        isPanelVisible = false

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            isHostPresented = true
        }
    }

    private func revealPanel() {
        guard isPresented, isHostPresented, !isPanelVisible else { return }

        withAnimation(.snappy) {
            isPanelVisible = true
        }
    }

    private func dismissPanel() {
        guard isHostPresented else {
            isPanelVisible = false
            isKeyboardPresented = false
            return
        }

        guard isPanelVisible else {
            dismissHost()
            return
        }

        withAnimation(.snappy, completionCriteria: .logicallyComplete) {
            isPanelVisible = false
        } completion: {
            Task { @MainActor in
                guard !isPresented else {
                    revealPanel()
                    return
                }

                dismissHost()
            }
        }
    }

    private func dismissHost() {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            isHostPresented = false
        }

        isKeyboardPresented = false
    }

    private var dismissGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($dragOffset) { value, state, _ in
                state = max(0, value.translation.height)
            }
            .onEnded { value in
                if value.translation.height > 80 {
                    isPresented = false
                }
            }
    }

    private func dragHandleHeight(
        _ specification: DSWheelPickerPanel.Specification
    ) -> CGFloat {
        specification.topPadding
            + specification.dragIndicatorHeight
            + specification.dragIndicatorToHeaderSpacing
    }
}

enum DSWheelPickerSheetBottomSpacingResolver {
    static func resolvedSpacing(
        defaultSpacing: CGFloat,
        keyboardSpacing: CGFloat,
        safeAreaBottom: CGFloat,
        safeAreaSpacing: CGFloat?,
        isKeyboardPresented: Bool
    ) -> CGFloat {
        guard !isKeyboardPresented else { return keyboardSpacing }
        guard let safeAreaSpacing else { return defaultSpacing }

        return max(safeAreaBottom, 0) + max(safeAreaSpacing, 0)
    }
}

private struct DSWheelPickerWindowSafeAreaReader: UIViewRepresentable {
    @Binding var bottomInset: CGFloat

    func makeUIView(context: Context) -> DSWheelPickerSafeAreaView {
        let view = DSWheelPickerSafeAreaView()
        configure(view)
        return view
    }

    func updateUIView(_ uiView: DSWheelPickerSafeAreaView, context: Context) {
        configure(uiView)
    }

    private func configure(_ view: DSWheelPickerSafeAreaView) {
        let bottomInset = $bottomInset
        view.onWindowSafeAreaInsetsChange = { value in
            guard bottomInset.wrappedValue != value else { return }

            DispatchQueue.main.async {
                bottomInset.wrappedValue = value
            }
        }
        view.reportWindowSafeAreaInsets()
    }
}

private final class DSWheelPickerSafeAreaView: UIView {
    var onWindowSafeAreaInsetsChange: ((CGFloat) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        reportWindowSafeAreaInsets()
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        reportWindowSafeAreaInsets()
    }

    func reportWindowSafeAreaInsets() {
        guard let window else { return }
        onWindowSafeAreaInsetsChange?(window.safeAreaInsets.bottom)
    }
}
