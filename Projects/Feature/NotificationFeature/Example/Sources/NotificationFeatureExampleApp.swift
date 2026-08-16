import DesignSystem
import NotificationFeature
import SwiftUI

@main
struct NotificationFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ExampleContentView()
                .dsDebugLayoutInspector()
        }
    }
}
