import SwiftUI
import DesignSystem

@main
struct DesignSystemExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Colors") {
                    Text("Brand Colors will be listed here")
                }
                Section("Fonts") {
                    Text("Typography styles will be listed here")
                }
                Section("Components") {
                    Text("UI components will be listed here")
                }
            }
            .navigationTitle("Design System Catalog")
        }
    }
}
