import SwiftUI
import OnboardingFeature

struct ExampleContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("OnboardingFeature Example")
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
