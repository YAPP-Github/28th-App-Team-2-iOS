import SwiftUI
import LuckyActionFeature

struct ExampleContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("LuckyActionFeature Example")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("This is a standalone sample app.")
                Spacer()
            }
            .padding()
            .navigationTitle("LuckyActionFeature")
        }
    }
}
