import SwiftUI

public struct DSProgressBar: View {
    public struct Specification: Sendable {
        public let height: CGFloat
        public let leadingPadding: CGFloat
        public let trailingPadding: CGFloat
        public let contentGap: CGFloat
        public let backIconAsset: DSIconAsset
        public let backIconSize: CGSize
        public let backIconTintAsset: DesignSystemColors
        public let trackHeight: CGFloat
        public let trackBackgroundGradient: [DesignSystemColors]
        public let trackBackgroundOpacity: Double
        public let trackFillGradient: [DesignSystemColors]
        public let trackFillGradientLocations: [CGFloat]
        public let trackShape: DSComponentShape
    }

    public static func specification() -> Specification {
        Specification(
            height: 48,
            leadingPadding: 20,
            trailingPadding: 21,
            contentGap: 24,
            backIconAsset: .chevronLeftPlain,
            backIconSize: CGSize(width: 12, height: 18),
            backIconTintAsset: DesignSystemAsset.Colors.gray400,
            trackHeight: 6,
            trackBackgroundGradient: [DesignSystemAsset.Colors.gray50, DesignSystemAsset.Colors.gray200],
            trackBackgroundOpacity: 0.5,
            trackFillGradient: [
                DesignSystemAsset.Colors.sky400,
                DesignSystemAsset.Colors.primary600,
                DesignSystemAsset.Colors.primary400
            ],
            trackFillGradientLocations: [0, 0.5, 1],
            trackShape: .roundedRectangle(cornerRadius: 10)
        )
    }

    private let progress: Double // 0.0 to 1.0
    private let onBack: () -> Void

    public init(progress: Double, onBack: @escaping () -> Void) {
        self.progress = max(0, min(1, progress))
        self.onBack = onBack
    }

    public var body: some View {
        let spec = Self.specification()

        HStack(spacing: spec.contentGap) {
            Button(action: onBack) {
                DSIcon(
                    spec.backIconAsset,
                    width: spec.backIconSize.width,
                    height: spec.backIconSize.height
                )
                .foregroundColor(spec.backIconTintAsset.swiftUIColor)
            }
            .buttonStyle(.plain)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    spec.trackShape.swiftUIShape
                        .fill(
                            LinearGradient(
                                colors: spec.trackBackgroundGradient.map(\.swiftUIColor),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(spec.trackBackgroundOpacity)
                        .dsDebugDetailGeometry("DSProgressBar.TrackBackground")

                    spec.trackShape.swiftUIShape
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    stops: zip(
                                        spec.trackFillGradient,
                                        spec.trackFillGradientLocations
                                    ).map { asset, location in
                                        Gradient.Stop(
                                            color: asset.swiftUIColor,
                                            location: location
                                        )
                                    }
                                ),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .mask(alignment: .leading) {
                            spec.trackShape.swiftUIShape
                                .frame(
                                    width: proxy.size.width * progress,
                                    height: spec.trackHeight
                                )
                                .dsDebugDetailGeometry("DSProgressBar.TrackFill")
                        }
                }
                .frame(height: spec.trackHeight)
            }
            .frame(maxWidth: .infinity)
            .frame(height: spec.trackHeight)
        }
        .padding(.leading, spec.leadingPadding)
        .padding(.trailing, spec.trailingPadding)
        .frame(maxWidth: .infinity)
        .frame(height: spec.height)
        .dsDebugGeometry("DSProgressBar")
    }
}
