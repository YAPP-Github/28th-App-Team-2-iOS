import DesignSystem
import SwiftUI

struct FortuneCategorySection: View {
    let categoryScores: [FortuneCategoryScore]
    let selectionAction: (FortuneCategory) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("상세 운세")
                .dsBody1Bold
                .foregroundStyle(Color.ds.gray975)
                .padding(.horizontal, 20)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(categoryScores, id: \.category) { item in
                        FortuneCategoryCard(item: item) {
                            selectionAction(item.category)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, 20, for: .scrollContent)
        }
    }
}

private struct FortuneCategoryCard: View {
    let item: FortuneCategoryScore
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(item.category.title)
                            .dsCaption1Medium
                            .foregroundStyle(Color.ds.gray600)

                        Spacer(minLength: 0)

                        Circle()
                            .fill(Color.ds.white)
                            .frame(width: 20, height: 20)
                            .overlay {
                                DSIcon(.chevronSmallRight, width: 14, height: 14)
                                    .foregroundStyle(Color.ds.gray400)
                            }
                    }

                    Text("\(item.score)점")
                        .dsBody1Bold
                        .foregroundStyle(Color.ds.gray975)
                }
                .frame(width: 93, alignment: .leading)
                .padding(.top, 14)
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                item.category.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .padding(8)
                    .accessibilityHidden(true)
            }
            .frame(width: 120, height: 120)
            .background(Color.ds.gray50)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .dsSurfaceButtonStyle(shape: .roundedRectangle(cornerRadius: 16))
        .accessibilityLabel("\(item.category.title) \(item.score)점")
        .accessibilityHint("상세 운세 리포트를 엽니다")
    }
}

private extension FortuneCategory {
    var image: SwiftUI.Image {
        switch self {
        case .relationship:
            FortuneFeatureAsset.Images.fortuneCategoryRelationship.swiftUIImage
        case .love:
            FortuneFeatureAsset.Images.fortuneCategoryLove.swiftUIImage
        case .achievement:
            FortuneFeatureAsset.Images.fortuneCategoryAchievement.swiftUIImage
        case .health:
            FortuneFeatureAsset.Images.fortuneCategoryHealth.swiftUIImage
        case .money:
            FortuneFeatureAsset.Images.fortuneCategoryMoney.swiftUIImage
        }
    }
}
