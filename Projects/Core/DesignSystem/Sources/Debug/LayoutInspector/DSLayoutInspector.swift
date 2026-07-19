#if DEBUG
import SwiftUI

public extension View {
    /// DEBUG 빌드에서 플로팅 핸들로 열 수 있는 레이아웃 검사기를 설치합니다.
    func dsDebugLayoutInspector() -> some View {
        modifier(DSLayoutInspectorModifier())
    }
}

private struct DSLayoutInspectorModifier: ViewModifier {
    @State private var isPresented = false
    @State private var handleOffset: CGFloat = 0
    @GestureState private var handleDragOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .environment(\.dsLayoutInspectorEnabled, isPresented)
            .overlay {
                if !isPresented {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()

                            DSLayoutInspectorActivationHandle {
                                isPresented = true
                            }
                            .offset(
                                y: clampedHandleOffset(
                                    handleOffset + handleDragOffset,
                                    availableHeight: geometry.size.height
                                )
                            )
                            .highPriorityGesture(handleDragGesture(in: geometry.size.height))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .overlayPreferenceValue(DSLayoutDebugPreferenceKey.self) { nodes in
                GeometryReader { geometry in
                    if isPresented {
                        DSLayoutInspectorOverlay(
                            menuOffset: $handleOffset,
                            reportedRegions: reportedRegions(
                                from: nodes,
                                in: geometry
                            ),
                            layoutSize: geometry.size,
                            layoutSafeAreaInsets: geometry.safeAreaInsets
                        ) {
                            isPresented = false
                        }
                        .transition(.opacity)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isPresented)
    }

    private func reportedRegions(
        from nodes: [DSLayoutDebugNode],
        in geometry: GeometryProxy
    ) -> [DSLayoutRegion] {
        nodes.enumerated().compactMap { index, node in
            let localFrame = geometry[node.bounds]
            let overlayOrigin = geometry.frame(in: .global).origin
            let frame = localFrame.offsetBy(
                dx: overlayOrigin.x,
                dy: overlayOrigin.y
            )
            guard frame.width >= 1,
                  frame.height >= 1,
                  [frame.minX, frame.minY, frame.width, frame.height]
                    .allSatisfy(\.isFinite) else {
                return nil
            }

            return DSLayoutRegion(
                regionID: node.regionID,
                name: node.name,
                frame: frame,
                depth: index,
                source: node.source,
                suppressesContainedAutomaticRegions:
                    node.suppressesContainedAutomaticRegions
            )
        }
    }

    private func handleDragGesture(in availableHeight: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($handleDragOffset) { gesture, offset, _ in
                offset = gesture.translation.height
            }
            .onEnded { gesture in
                handleOffset = clampedHandleOffset(
                    handleOffset + gesture.translation.height,
                    availableHeight: availableHeight
                )
            }
    }

    private func clampedHandleOffset(
        _ offset: CGFloat,
        availableHeight: CGFloat
    ) -> CGFloat {
        let maximumOffset = max(availableHeight / 2 - 60, 0)
        return min(max(offset, -maximumOffset), maximumOffset)
    }
}
#endif
