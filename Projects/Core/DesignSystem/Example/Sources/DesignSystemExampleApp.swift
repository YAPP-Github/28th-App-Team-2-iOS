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
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ColorCatalogView()
                    .tabItem {
                        Label("Colors", systemImage: "paintpalette")
                    }
                    .tag(0)
                
                FontCatalogView()
                    .tabItem {
                        Label("Fonts", systemImage: "textformat")
                    }
                    .tag(1)
                

                IconCatalogView()
                    .tabItem {
                        Label("Icons", systemImage: "star")
                    }
                    .tag(2)
                
                ComponentsCatalogView()
                    .tabItem {
                        Label("Components", systemImage: "square.grid.2x2")
                    }
                    .tag(3)
            }
            .navigationTitle(navigationTitle(for: selectedTab))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func navigationTitle(for tab: Int) -> String {
        switch tab {
        case 0: return "Color Palette"
        case 1: return "Typography"
        case 2: return "Icons"
        case 3: return "Components"
        default: return "Catalog"
        }
    }
}
