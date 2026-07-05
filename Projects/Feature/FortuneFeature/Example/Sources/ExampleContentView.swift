import SwiftUI
import FortuneFeature

struct ExampleContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("FortuneFeature Example")
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
