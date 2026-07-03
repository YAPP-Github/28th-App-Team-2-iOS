import SwiftUI
import AssistantFeature

struct DemoContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("AssistantFeature Demo")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("This is a standalone sample app.")
                Spacer()
            }
            .padding()
            .navigationTitle("AssistantFeature")
        }
    }
}
