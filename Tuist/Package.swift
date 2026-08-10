// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "todakunDependencies",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.25.5")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMajor(from: "2.28.0"))
    ]
)
