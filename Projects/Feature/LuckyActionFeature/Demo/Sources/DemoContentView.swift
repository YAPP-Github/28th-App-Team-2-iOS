import SwiftUI
import LuckyActionFeature

struct DemoContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("LuckyActionFeature Demo")
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
