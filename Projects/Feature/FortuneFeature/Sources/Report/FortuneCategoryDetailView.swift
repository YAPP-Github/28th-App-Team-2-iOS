import ComposableArchitecture
import DesignSystem
import SwiftUI

struct FortuneCategoryDetailView: View {
    let store: StoreOf<FortuneCategoryDetailFeature>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                switch store.viewState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 240)
                        
                case let .failed(message):
                    VStack(spacing: 16) {
                        Text(message)
                            .dsBody3Regular
                            .foregroundStyle(Color.ds.gray700)
                            
                        DSButton("다시 시도", size: .medium) {
                            store.send(.retryTapped)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                    
                case let .loaded(detail):
                    loadedContent(detail)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.ds.white)
        .task {
            await store.send(.task).finish()
        }
    }
    
    private var header: some View {
        HStack {
            Text("오늘의 \(store.category.title)")
                .dsHeading4Bold
                .foregroundStyle(Color.ds.gray975)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.ds.gray900)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.top, 8)
    }

    private func loadedContent(_ detail: LuckActionDetail) -> some View {
        VStack(alignment: .center, spacing: 0) {
            HalfCircularGaugeView(score: detail.score)
                .padding(.top, 40)
                .padding(.bottom, 48)
                
            VStack(spacing: 8) {
                Text("오늘의 행운 액션")
                    .dsBody3Medium
                    .foregroundStyle(Color.ds.primary500)
                    
                Text(detail.title)
                    .dsBody2SemiBold
                    .foregroundStyle(Color.ds.gray975)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(Color.ds.gray50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            Text(detail.content)
                .dsBody3Regular
                .foregroundStyle(Color.ds.gray975)
                .lineSpacing(6)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
            DSPrimaryLargeButton("토닥이에게 더 물어보기") {
                store.send(.todakTapped)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

private struct HalfCircularGaugeView: View {
    let score: Int
    
    var body: some View {
        let level = FortuneMoodLevel(score: Double(score))
        
        ZStack(alignment: .bottom) {
            ZStack {
                Circle()
                    .trim(from: 0.5, to: 1.0)
                    .stroke(Color.ds.gray100, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                
                Circle()
                    .trim(from: 0.5, to: 0.5 + CGFloat(score) / 100.0 * 0.5)
                    .stroke(level.gaugeGradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
            }
            .frame(width: 200, height: 200)
            .padding(10)
            .frame(height: 110, alignment: .top)
            .clipped()
            
            Text("\(score)점")
                .dsHeading1ExtraBold
                .foregroundStyle(level.scoreColor)
                .padding(.bottom, -8)
        }
        .frame(width: 220, height: 110)
    }
}

private extension FortuneMoodLevel {
    var scoreColor: Color {
        switch self {
        case .level01: return Color(red: 247/255, green: 139/255, blue: 139/255)
        case .level02: return Color(red: 23/255, green: 144/255, blue: 130/255)
        case .level03: return Color(red: 138/255, green: 165/255, blue: 255/255)
        case .level04: return Color(red: 127/255, green: 115/255, blue: 234/255)
        }
    }
    
    var gaugeGradient: LinearGradient {
        switch self {
        case .level01:
            return LinearGradient(colors: [Color(red: 255/255, green: 194/255, blue: 194/255), scoreColor], startPoint: .leading, endPoint: .trailing)
        case .level02:
            return LinearGradient(colors: [Color(red: 183/255, green: 232/255, blue: 227/255), Color(red: 77/255, green: 213/255, blue: 197/255)], startPoint: .leading, endPoint: .trailing)
        case .level03:
            return LinearGradient(colors: [Color(red: 192/255, green: 206/255, blue: 255/255), scoreColor], startPoint: .leading, endPoint: .trailing)
        case .level04:
            return LinearGradient(colors: [Color(red: 138/255, green: 165/255, blue: 255/255), scoreColor], startPoint: .leading, endPoint: .trailing)
        }
    }
}
