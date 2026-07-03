import SwiftUI
import ActionFeature

struct DemoContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("ActionFeature Demo")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("This is a standalone sample app.")
                Spacer()
            }
            .padding()
            .navigationTitle("ActionFeature")
        }
    }
}
