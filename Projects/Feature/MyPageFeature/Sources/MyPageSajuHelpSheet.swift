import DesignSystem
import SwiftUI

struct MyPageSajuHelpSheet: View {
    let sheet: MyPageFeature.HelpSheet
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(sheet.title)
                .dsBody1Bold
                .foregroundStyle(Color.ds.gray975)

            Text(sheet.description)
                .dsBody2Medium
                .foregroundStyle(Color.ds.gray975)
                .padding(.top, 32)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(sheet.items, id: \.self) { item in
                    Text("•  \(item)")
                        .dsBody3Medium
                        .foregroundStyle(Color.ds.gray975)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.ds.gray25, in: RoundedRectangle(cornerRadius: 12))
            .padding(.top, 24)

            Spacer(minLength: 24)

            DSPrimaryLargeButton("확인", action: onConfirm)
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 20)
    }
}

extension MyPageFeature.HelpSheet {
    var title: String {
        switch self {
        case .sajuOriginal: "사주원국이란?"
        case .ohaeng: "오행이란?"
        }
    }

    var description: String {
        switch self {
        case .sajuOriginal:
            "사주원국은 태어난 연/월/일/시를 각각 천간(하늘의 기운)과 지지(땅의 기운)로 나타낸, "
                + "타고난 사주의 기본 틀이에요. 이 네 기둥(사주)이 모여 한 사람이 타고난 기질과 운의 전체 지도를 보여줘요."
        case .ohaeng:
            "오행은 우주 만물을 이루는 다섯 가지 기운, 목(木)·화(火)·토(土)·금(金)·수(水)를 뜻해요. 오행의 균형이 성격과 운의 흐름에 영향을 줘요."
        }
    }

    var items: [String] {
        switch self {
        case .sajuOriginal:
            [
                "년주: 태어난 해의 천간·지지 → 조상, 어린 시절, 사회적 배경을 의미",
                "월주: 태어난 달의 천간·지지 → 부모, 형제, 성장 환경을 의미",
                "일주: 태어난 날의 천간·지지 → 나 자신, 배우자를 의미 (사주의 중심)",
                "시주: 태어난 시각의 천간·지지 → 자녀, 말년운을 의미"
            ]
        case .ohaeng:
            [
                "목(木): 성장과 시작의 기운 (봄, 나무)",
                "화(火): 열정과 확산의 기운 (여름, 불)",
                "토(土): 중심과 안정의 기운 (환절기, 흙)",
                "금(金): 결실과 결단의 기운 (가을, 쇠)",
                "수(水): 지혜와 휴식의 기운 (겨울, 물)"
            ]
        }
    }

    var detentHeight: CGFloat {
        switch self {
        case .sajuOriginal: 543
        case .ohaeng: 481
        }
    }
}
