import SwiftUI
import MyPageFeature

struct DemoContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("MyPageFeature Demo")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("This is a standalone sample app.")
                Spacer()
            }
            .padding()
            .navigationTitle("MyPageFeature")
        }
    }
}
