import SwiftUI
import FortuneFeature

struct DemoContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("FortuneFeature Demo")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("This is a standalone sample app.")
                Spacer()
            }
            .padding()
            .navigationTitle("FortuneFeature")
        }
    }
}
