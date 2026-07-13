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
        TabView {
            NavigationStack {
                ColorCatalogView()
                    .navigationTitle("Color Palette")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Colors", systemImage: "paintpalette")
            }

            NavigationStack {
                FontCatalogView()
                    .navigationTitle("Typography")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Fonts", systemImage: "textformat")
            }

            NavigationStack {
                IconCatalogView()
                    .navigationTitle("Icons")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Icons", systemImage: "star")
            }

            NavigationStack {
                ComponentsCatalogView()
                    .navigationTitle("Components")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Components", systemImage: "square.grid.2x2")
            }
        }
    }
}
