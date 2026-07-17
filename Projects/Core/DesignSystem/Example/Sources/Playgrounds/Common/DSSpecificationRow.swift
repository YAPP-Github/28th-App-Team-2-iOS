import SwiftUI

struct DSSpecificationRow: View {
    private let title: String
    private let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.footnote)
    }
}
