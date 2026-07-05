import SwiftUI
import MyPageFeature

struct ExampleContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("MyPageFeature Example")
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
