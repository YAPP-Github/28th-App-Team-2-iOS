// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "todakunDependencies",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.25.5"))
    ]
)
