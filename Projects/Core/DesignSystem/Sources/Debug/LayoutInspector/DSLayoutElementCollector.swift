#if DEBUG
import UIKit

@MainActor
enum DSLayoutElementCollector {
    static func collect() -> [DSLayoutRegion] {
        guard let window = activeWindow() else { return [] }

        var regions: [DSLayoutRegion] = []
        var accessibilityObjects = Set<ObjectIdentifier>()
        collectViews(
            from: window,
            in: window,
            depth: 0,
            regions: &regions,
            accessibilityObjects: &accessibilityObjects
        )

        return DSLayoutRegionMerger.deduplicateAutomatic(
            regions,
            displayScale: window.screen.scale
        )
    }

    static func safeAreaInsets() -> UIEdgeInsets {
        activeWindow()?.safeAreaInsets ?? .zero
    }

    static func currentScreenName() -> String {
        guard let window = activeWindow() else { return "알 수 없음" }

        if let navigationTitle = navigationTitle(in: window) {
            return navigationTitle
        }

        guard let rootViewController = window.rootViewController else {
            return String(describing: type(of: window))
        }

        return String(
            describing: type(
                of: visibleViewController(from: rootViewController)
            )
        )
    }

    private static func activeWindow() -> UIWindow? {
        let activeScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        return activeScenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
            ?? activeScenes.flatMap(\.windows).first(where: { !$0.isHidden })
    }

    private static func navigationTitle(in view: UIView) -> String? {
        if let navigationBar = view as? UINavigationBar,
           let title = navigationBar.topItem?.title,
           !title.isEmpty {
            return title
        }

        for subview in view.subviews.reversed() {
            if let title = navigationTitle(in: subview) {
                return title
            }
        }

        return nil
    }

    private static func visibleViewController(
        from viewController: UIViewController
    ) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController,
           !presentedViewController.isBeingDismissed {
            return visibleViewController(from: presentedViewController)
        }

        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return self.visibleViewController(from: visibleViewController)
        }

        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return visibleViewController(from: selectedViewController)
        }

        if let visibleChild = viewController.children.reversed().first(where: {
            $0.viewIfLoaded?.window != nil
        }) {
            return visibleViewController(from: visibleChild)
        }

        return viewController
    }

    private static func collectViews(
        from view: UIView,
        in window: UIWindow,
        depth: Int,
        regions: inout [DSLayoutRegion],
        accessibilityObjects: inout Set<ObjectIdentifier>
    ) {
        guard isVisible(view),
              !isInspectorElement(view),
              view.window === window || view === window else {
            return
        }

        let frame = view.convert(view.bounds, to: window)
        if view !== window, isUsable(frame, in: window.bounds) {
            regions.append(
                DSLayoutRegion(
                    regionID: "view-\(ObjectIdentifier(view))",
                    name: regionName(for: view),
                    frame: frame,
                    depth: depth,
                    source: .view
                )
            )
        }

        collectAccessibility(
            from: view,
            in: window,
            depth: depth + 1,
            regions: &regions,
            visited: &accessibilityObjects
        )

        for subview in view.subviews {
            collectViews(
                from: subview,
                in: window,
                depth: depth + 1,
                regions: &regions,
                accessibilityObjects: &accessibilityObjects
            )
        }
    }

    private static func collectAccessibility(
        from object: NSObject,
        in window: UIWindow,
        depth: Int,
        regions: inout [DSLayoutRegion],
        visited: inout Set<ObjectIdentifier>
    ) {
        let objectID = ObjectIdentifier(object)
        guard visited.insert(objectID).inserted,
              !object.accessibilityElementsHidden,
              !isInspectorElement(object) else {
            return
        }

        if object.isAccessibilityElement {
            let frame = window.screen.coordinateSpace.convert(
                object.accessibilityFrame,
                to: window.coordinateSpace
            )

            if isUsable(frame, in: window.bounds) {
                regions.append(
                    DSLayoutRegion(
                        regionID: "accessibility-\(objectID)",
                        name: accessibilityName(for: object),
                        frame: frame,
                        depth: depth,
                        source: .accessibility
                    )
                )
            }
        }

        for child in accessibilityChildren(of: object) {
            collectAccessibility(
                from: child,
                in: window,
                depth: depth + 1,
                regions: &regions,
                visited: &visited
            )
        }
    }

    private static func accessibilityChildren(of object: NSObject) -> [NSObject] {
        var children: [NSObject] = []

        if let elements = object.accessibilityElements, !elements.isEmpty {
            children.append(contentsOf: elements.compactMap { $0 as? NSObject })
        } else {
            let elementCount = min(max(object.accessibilityElementCount(), 0), 1_000)
            if elementCount > 0 {
                children.append(contentsOf: (0 ..< elementCount).compactMap {
                    object.accessibilityElement(at: $0) as? NSObject
                })
            }
        }

        if let automationElements = object.automationElements {
            children.append(contentsOf: automationElements.compactMap { $0 as? NSObject })
        }

        var objectIDs = Set<ObjectIdentifier>()
        return children.filter { child in
            objectIDs.insert(ObjectIdentifier(child)).inserted
        }
    }

    private static func isVisible(_ view: UIView) -> Bool {
        !view.isHidden
            && view.alpha > 0.01
            && !view.bounds.isEmpty
    }

    private static func isUsable(_ frame: CGRect, in bounds: CGRect) -> Bool {
        frame.isFinite
            && frame.width >= 1
            && frame.height >= 1
            && frame.intersects(bounds)
    }

    private static func isInspectorElement(_ object: NSObject) -> Bool {
        let accessibilityIdentifier: String?

        if let view = object as? UIView {
            accessibilityIdentifier = view.accessibilityIdentifier
        } else if let element = object as? UIAccessibilityElement {
            accessibilityIdentifier = element.accessibilityIdentifier
        } else {
            accessibilityIdentifier = nil
        }

        return accessibilityIdentifier?
            .hasPrefix(DSLayoutInspectorConstants.accessibilityPrefix) == true
    }

    private static func regionName(for view: UIView) -> String {
        if let label = view.accessibilityLabel, !label.isEmpty {
            return "\(type(of: view)) · \(label)"
        }
        return String(describing: type(of: view))
    }

    private static func accessibilityName(for object: NSObject) -> String {
        if let label = object.accessibilityLabel, !label.isEmpty {
            return label
        }
        return String(describing: type(of: object))
    }

}

private extension CGRect {
    var isFinite: Bool {
        [minX, minY, width, height].allSatisfy(\.isFinite)
    }
}
#endif
