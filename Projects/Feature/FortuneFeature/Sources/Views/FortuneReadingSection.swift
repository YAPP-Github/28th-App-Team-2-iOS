import DesignSystem
import SwiftUI

struct FortuneReadingSection: View {
    let selectionAction: (FortuneReading) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("사주 풀이")
                .dsBody1Bold
                .foregroundStyle(Color.ds.gray975)
                .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(FortuneReading.allCases, id: \.self) { reading in
                    FortuneReadingCard(reading: reading) {
                        selectionAction(reading)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct FortuneReadingCard: View {
    let reading: FortuneReading
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.ds.primary50)
                    .frame(width: 44, height: 44)
                    .overlay {
                        reading.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(reading.title)
                        .dsBody2SemiBold
                        .foregroundStyle(Color.ds.gray975)

                    Text(reading.subtitle)
                        .dsBody3Regular
                        .foregroundStyle(Color.ds.gray700)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(Color.ds.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.ds.gray100, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .dsSurfaceButtonStyle(shape: .roundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

private extension FortuneReading {
    var image: SwiftUI.Image {
        switch self {
        case .compatibility:
            FortuneFeatureAsset.Images.fortuneReadingCompatibility.swiftUIImage
        case .dateSelection:
            FortuneFeatureAsset.Images.fortuneReadingDateSelection.swiftUIImage
        case .yearly:
            FortuneFeatureAsset.Images.fortuneReadingYearly.swiftUIImage
        }
    }
}
