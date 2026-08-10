import DesignSystem
import FortuneFeature
import SwiftUI

@main
struct FortuneFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
#if DEBUG
            ExampleContentView()
                .dsDebugLayoutInspector()
#else
            ExampleContentView()
#endif
        }
    }
}
