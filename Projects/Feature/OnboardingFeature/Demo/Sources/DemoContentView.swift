import SwiftUI
import OnboardingFeature

struct DemoContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("OnboardingFeature Demo")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Text("This is a standalone sample app.")
                Spacer()
            }
            .padding()
            .navigationTitle("OnboardingFeature")
        }
    }
}
