import SwiftUI
import UIKit

public extension View {
    func dsWheelPickerDismissKeyboardOnTap() -> some View {
        modifier(DSWheelPickerKeyboardDismissModifier())
    }
}

private struct DSWheelPickerKeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DSWheelPickerKeyboardDismissTapInstaller())
    }
}

private struct DSWheelPickerKeyboardDismissTapInstaller: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WindowObservationView {
        let view = WindowObservationView()
        view.isUserInteractionEnabled = false
        view.onWindowChange = { [weak coordinator = context.coordinator] window in
            coordinator?.install(in: window)
        }
        return view
    }

    func updateUIView(_ uiView: WindowObservationView, context: Context) {
        context.coordinator.install(in: uiView.window)
    }

    static func dismantleUIView(
        _ uiView: WindowObservationView,
        coordinator: Coordinator
    ) {
        uiView.onWindowChange = nil
        coordinator.uninstall()
    }
}

private extension DSWheelPickerKeyboardDismissTapInstaller {
    final class WindowObservationView: UIView {
        var onWindowChange: ((UIWindow?) -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            onWindowChange?(window)
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var installedWindow: UIWindow?
        private var keyboardObservers: [NSObjectProtocol] = []
        private var isKeyboardPresented = false
        private var shouldDismissForCurrentTap = false

        private lazy var tapRecognizer: UITapGestureRecognizer = {
            let recognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(handleTap)
            )
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            return recognizer
        }()

        override init() {
            super.init()

            keyboardObservers = [
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.isKeyboardPresented = true
                },
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.isKeyboardPresented = false
                }
            ]
        }

        deinit {
            keyboardObservers.forEach(NotificationCenter.default.removeObserver)
        }

        func install(in window: UIWindow?) {
            guard installedWindow !== window else { return }

            uninstall()
            installedWindow = window
            window?.addGestureRecognizer(tapRecognizer)
        }

        func uninstall() {
            installedWindow?.removeGestureRecognizer(tapRecognizer)
            installedWindow = nil
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            shouldDismissForCurrentTap = isKeyboardPresented
            return true
        }

        @objc
        private func handleTap() {
            guard shouldDismissForCurrentTap else { return }

            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
            shouldDismissForCurrentTap = false
        }
    }
}
