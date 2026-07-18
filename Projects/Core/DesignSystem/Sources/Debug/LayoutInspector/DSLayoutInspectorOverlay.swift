#if DEBUG
import SwiftUI
import UIKit

struct DSLayoutInspectorOverlay: View {
    enum Mode {
        case inspection
        case spacing
        case ruler
    }

    @Binding var menuOffset: CGFloat
    let reportedRegions: [DSLayoutRegion]
    let layoutSize: CGSize
    let layoutSafeAreaInsets: EdgeInsets
    let onClose: () -> Void

    @Environment(\.displayScale) private var displayScale

    @State private var mode: Mode = .inspection
    @State private var automaticRegions: [DSLayoutRegion] = []
    @State private var selectedRegionIDs: [String] = []
    @State private var rulerPoints = DSLayoutRulerPoints.empty
    @State private var safeAreaInsets = UIEdgeInsets.zero
    @State private var currentScreenName = "알 수 없음"
    @State private var informationOffset: CGFloat = 0
    @State private var informationPanelHeight: CGFloat = 0
    @GestureState private var menuDragOffset: CGFloat = 0
    @GestureState private var informationDragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            interactionLayer
                .accessibilityHidden(true)
            regionOutlines
                .accessibilityHidden(true)
            measurementOverlay
                .accessibilityHidden(true)
            controlPanel
        }
        .ignoresSafeArea()
        .task(id: refreshIdentity) {
            await refreshAfterPresentation()
        }
        .onChange(of: mode) {
            selectedRegionIDs.removeAll()
            rulerPoints = .empty
        }
    }

    @ViewBuilder
    private var interactionLayer: some View {
        switch mode {
        case .inspection, .spacing:
            Color.black.opacity(0.001)
                .contentShape(Rectangle())
                .gesture(
                    SpatialTapGesture()
                        .onEnded { gesture in
                            selectRegion(at: gesture.location)
                        }
                )
        case .ruler:
            Color.black.opacity(0.001)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { gesture in
                            guard DSLayoutRulerPoints.isDrag(
                                translation: gesture.translation
                            ) else { return }

                            rulerPoints = .drag(
                                from: gesture.startLocation,
                                to: gesture.location
                            )
                        }
                        .onEnded { gesture in
                            if DSLayoutRulerPoints.isDrag(
                                translation: gesture.translation
                            ) {
                                rulerPoints = .drag(
                                    from: gesture.startLocation,
                                    to: gesture.location
                                )
                            } else {
                                rulerPoints = rulerPoints.afterTapping(gesture.location)
                            }
                        }
                )
        }
    }

    private var regionOutlines: some View {
        ForEach(Array(regions.prefix(250)), id: \.regionID) { region in
            Rectangle()
                .stroke(
                    outlineColor(for: region.source),
                    lineWidth: 0.5
                )
                .frame(width: region.frame.width, height: region.frame.height)
                .position(x: region.frame.midX, y: region.frame.midY)
                .allowsHitTesting(false)
        }
        .overlay {
            ForEach(selectedRegions, id: \.regionID) { region in
                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: region.frame.width, height: region.frame.height)
                    .position(x: region.frame.midX, y: region.frame.midY)
            }
        }
        .allowsHitTesting(false)
    }

    private var measurementOverlay: some View {
        ZStack {
            ForEach(measurements, id: \.measurementID) { measurement in
                DSLayoutMeasurementView(measurement: measurement)
            }

            if let rulerStart = rulerPoints.start {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(rulerStart)
            }

            if let rulerEnd = rulerPoints.end {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(rulerEnd)
            }
        }
        .allowsHitTesting(false)
    }

    private var controlPanel: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Spacer()

                    VStack(spacing: 8) {
                        inspectorButton(
                            title: "정보",
                            systemImage: "viewfinder",
                            isActive: mode == .inspection
                        ) {
                            mode = .inspection
                        }

                        inspectorButton(
                            title: "간격",
                            systemImage: "arrow.left.and.right",
                            isActive: mode == .spacing
                        ) {
                            mode = .spacing
                        }

                        inspectorButton(
                            title: "자",
                            systemImage: "ruler",
                            isActive: mode == .ruler
                        ) {
                            mode = .ruler
                        }

                        inspectorButton(
                            title: "새로고침",
                            systemImage: "arrow.clockwise",
                            isActive: false,
                            action: refresh
                        )

                        inspectorButton(
                            title: "닫기",
                            systemImage: "xmark",
                            isActive: false,
                            action: onClose
                        )
                    }
                    .offset(
                        y: DSLayoutInspectorPositionCalculator.menuOffset(
                            menuOffset + menuDragOffset,
                            availableHeight: geometry.size.height,
                            safeAreaInsets: safeAreaInsets
                        )
                    )
                    .highPriorityGesture(
                        menuDragGesture(in: geometry.size.height)
                    )
                }
                .padding(.trailing, 12)

                VStack {
                    Spacer()

                    DSLayoutInspectorInformationPanel(
                        mode: mode,
                        selectedRegionCount: selectedRegions.count,
                        selectedRegion: selectedRegions.last,
                        rulerPointCount: rulerPointCount,
                        currentScreenName: currentScreenName
                    )
                        .background {
                            GeometryReader { panelGeometry in
                                Color.clear.preference(
                                    key: DSLayoutInspectorInformationHeightKey.self,
                                    value: panelGeometry.size.height
                                )
                            }
                        }
                        .onPreferenceChange(DSLayoutInspectorInformationHeightKey.self) {
                            informationPanelHeight = $0
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, safeAreaInsets.bottom + 12)
                        .offset(
                            y: clampedInformationOffset(
                                informationOffset + informationDragOffset,
                                availableHeight: geometry.size.height
                            )
                        )
                        .highPriorityGesture(
                            informationDragGesture(in: geometry.size.height)
                        )
                }
            }
        }
    }
}

private extension DSLayoutInspectorOverlay {
    private var reportedRegionIdentity: String {
        reportedRegions
            .map { region in
                let frameIdentity = [
                    region.frame.minX,
                    region.frame.minY,
                    region.frame.width,
                    region.frame.height
                ]
                .map { String(Int(($0 * displayScale).rounded())) }
                .joined(separator: ":")
                return "\(region.regionID):\(frameIdentity)"
            }
            .sorted()
            .joined(separator: "|")
    }

    private var refreshIdentity: String {
        let layoutIdentity = [
            layoutSize.width,
            layoutSize.height,
            layoutSafeAreaInsets.top,
            layoutSafeAreaInsets.leading,
            layoutSafeAreaInsets.bottom,
            layoutSafeAreaInsets.trailing
        ]
            .map { String(Int(($0 * displayScale).rounded())) }
            .joined(separator: ":")
        return "\(reportedRegionIdentity)|\(layoutIdentity)"
    }

    private var selectedRegions: [DSLayoutRegion] {
        selectedRegionIDs.compactMap { selectedID in
            regions.first { $0.regionID == selectedID }
        }
    }

    private var regions: [DSLayoutRegion] {
        DSLayoutRegionMerger.merge(
            automaticRegions: automaticRegions,
            reportedRegions: reportedRegions,
            displayScale: displayScale
        )
    }

    private var measurements: [DSLayoutMeasurement] {
        if mode == .ruler,
           let rulerStart = rulerPoints.start,
           let rulerEnd = rulerPoints.end {
            return DSLayoutMeasurementCalculator.manualMeasurements(
                from: rulerStart,
                to: rulerEnd
            )
        }

        guard mode == .spacing, selectedRegions.count == 2 else { return [] }
        return DSLayoutMeasurementCalculator.measurements(
            between: selectedRegions[0].frame,
            and: selectedRegions[1].frame
        )
    }

    private var rulerPointCount: Int {
        [rulerPoints.start, rulerPoints.end].compactMap { $0 }.count
    }

    private func inspectorButton(
        title: String,
        systemImage: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 34, height: 34)
                .foregroundStyle(isActive ? .black : .white)
                .background(
                    isActive ? Color.yellow : Color.black.opacity(0.82),
                    in: RoundedRectangle(cornerRadius: 9)
                )
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(title)
        .accessibilityIdentifier(
            "\(DSLayoutInspectorConstants.accessibilityPrefix).\(title)"
        )
    }

    private func refresh() {
        automaticRegions = DSLayoutElementCollector.collect()
        safeAreaInsets = DSLayoutElementCollector.safeAreaInsets()
        currentScreenName = DSLayoutElementCollector.currentScreenName()
        selectedRegionIDs.removeAll()
        rulerPoints = .empty
    }

    private func refreshAfterPresentation() async {
        for delay in [0, 100, 300] {
            if delay > 0 {
                try? await Task.sleep(for: .milliseconds(delay))
            }

            refresh()
            if !automaticRegions.isEmpty { return }
        }
    }

    private func outlineColor(for source: DSLayoutRegionSource) -> Color {
        switch source {
        case .view:
            .orange
        case .accessibility:
            .cyan
        case .designSystem:
            .purple
        case .designSystemDetail:
            .mint
        }
    }

    private func informationDragGesture(in availableHeight: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4)
            .updating($informationDragOffset) { gesture, offset, _ in
                offset = gesture.translation.height
            }
            .onEnded { gesture in
                informationOffset = DSLayoutInspectorPositionCalculator.informationOffset(
                    informationOffset + gesture.translation.height,
                    availableHeight: availableHeight,
                    panelHeight: informationPanelHeight,
                    safeAreaInsets: safeAreaInsets
                )
            }
    }

    private func menuDragGesture(in availableHeight: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($menuDragOffset) { gesture, offset, _ in
                offset = gesture.translation.height
            }
            .onEnded { gesture in
                menuOffset = DSLayoutInspectorPositionCalculator.menuOffset(
                    menuOffset + gesture.translation.height,
                    availableHeight: availableHeight,
                    safeAreaInsets: safeAreaInsets
                )
            }
    }

    private func clampedInformationOffset(
        _ offset: CGFloat,
        availableHeight: CGFloat
    ) -> CGFloat {
        DSLayoutInspectorPositionCalculator.informationOffset(
            offset,
            availableHeight: availableHeight,
            panelHeight: informationPanelHeight,
            safeAreaInsets: safeAreaInsets
        )
    }

    func selectRegion(at point: CGPoint) {
        guard let region = DSLayoutMeasurementCalculator.region(
            at: point,
            in: regions
        ) else {
            selectedRegionIDs.removeAll()
            return
        }

        updateSelection(with: region)
    }

    func updateSelection(with region: DSLayoutRegion) {
        switch mode {
        case .inspection:
            selectedRegionIDs = DSLayoutMeasurementCalculator.inspectionSelectionIDs(
                afterSelecting: region.regionID,
                currentSelection: selectedRegionIDs
            )
        case .spacing:
            selectedRegionIDs = DSLayoutMeasurementCalculator.spacingSelectionIDs(
                afterSelecting: region.regionID,
                currentSelection: selectedRegionIDs
            )
        case .ruler:
            break
        }
    }
}
#endif
