import SwiftUI
import TodakFeature

struct DemoContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("TodakFeature Demo")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("This is a standalone sample app.")
                Spacer()
            }
            .padding()
            .navigationTitle("TodakFeature")
        }
    }
}
