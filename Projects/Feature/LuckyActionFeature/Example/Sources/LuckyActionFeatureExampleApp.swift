import DesignSystem
import LuckyActionFeature
import SwiftUI

@main
struct LuckyActionFeatureExampleApp: App {
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
