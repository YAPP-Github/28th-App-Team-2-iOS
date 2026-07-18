import SwiftUI

#if DEBUG
extension View {
    /// DEBUG 레이아웃 검사기에 이 View의 의미 있는 영역을 전달합니다.
    func dsDebugGeometry(
        _ name: @autoclosure @escaping () -> String
    ) -> some View {
        modifier(
            DSLayoutDebugGeometryModifier(
                name: name,
                source: .designSystem,
                suppressesContainedAutomaticRegions: false
            )
        )
    }
}

extension View {
    /// DesignSystem 컴포넌트의 내부 영역을 전달합니다.
    func dsDebugDetailGeometry(
        _ name: @autoclosure @escaping () -> String
    ) -> some View {
        modifier(
            DSLayoutDebugGeometryModifier(
                name: name,
                source: .designSystemDetail,
                suppressesContainedAutomaticRegions: false
            )
        )
    }

    /// DS 타이포그래피의 행간을 포함한 최종 line box를 전달합니다.
    func dsDebugTypographyGeometry(
        _ name: @autoclosure @escaping () -> String
    ) -> some View {
        modifier(
            DSLayoutDebugGeometryModifier(
                name: name,
                source: .designSystemDetail,
                suppressesContainedAutomaticRegions: true
            )
        )
    }
}

struct DSLayoutDebugNode {
    let regionID: String
    let name: String
    let bounds: Anchor<CGRect>
    let source: DSLayoutRegionSource
    let suppressesContainedAutomaticRegions: Bool
}

struct DSLayoutDebugPreferenceKey: PreferenceKey {
    static let defaultValue: [DSLayoutDebugNode] = []

    static func reduce(
        value: inout [DSLayoutDebugNode],
        nextValue: () -> [DSLayoutDebugNode]
    ) {
        value.append(contentsOf: nextValue())
    }
}

private struct DSLayoutInspectorEnabledKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var dsLayoutInspectorEnabled: Bool {
        get { self[DSLayoutInspectorEnabledKey.self] }
        set { self[DSLayoutInspectorEnabledKey.self] = newValue }
    }
}

private struct DSLayoutDebugGeometryModifier: ViewModifier {
    @Environment(\.dsLayoutInspectorEnabled) private var isInspectorEnabled
    @State private var regionID = UUID().uuidString
    @State private var isVisible = false

    let name: () -> String
    let source: DSLayoutRegionSource
    let suppressesContainedAutomaticRegions: Bool

    func body(content: Content) -> some View {
        content
            .onAppear {
                isVisible = true
            }
            .onDisappear {
                isVisible = false
            }
            .transformAnchorPreference(
                key: DSLayoutDebugPreferenceKey.self,
                value: .bounds
            ) { regions, bounds in
                guard isInspectorEnabled, isVisible else { return }

                regions.append(
                    DSLayoutDebugNode(
                        regionID: "geometry-\(regionID)",
                        name: name(),
                        bounds: bounds,
                        source: source,
                        suppressesContainedAutomaticRegions:
                            suppressesContainedAutomaticRegions
                    )
                )
            }
    }
}
#else
extension View {
    @inline(__always)
    func dsDebugGeometry(
        _ name: @autoclosure () -> String
    ) -> Self {
        self
    }

    @inline(__always)
    func dsDebugDetailGeometry(
        _ name: @autoclosure () -> String
    ) -> Self {
        self
    }

    @inline(__always)
    func dsDebugTypographyGeometry(
        _ name: @autoclosure () -> String
    ) -> Self {
        self
    }
}
#endif
