import SwiftUI
import MyFeature

struct DemoContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("MyFeature Demo")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("This is a standalone sample app.")
                Spacer()
            }
            .padding()
            .navigationTitle("MyFeature")
        }
    }
}
