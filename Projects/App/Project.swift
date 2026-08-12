import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeApp(
    name: "Todakun",
    dependencies: [
        .external(name: "ComposableArchitecture"),
        .external(name: "FirebaseCore"),
        .external(name: "FirebaseMessaging"),
        .external(name: "GoogleSignIn"),
        .external(name: "KakaoSDKAuth"),
        .external(name: "KakaoSDKCommon"),
        .project(target: "AuthSession", path: .relativeToRoot("Projects/Core/AuthSession")),
        .project(target: "DesignSystem", path: .relativeToRoot("Projects/Core/DesignSystem")),
        .project(target: "NetworkCore", path: .relativeToRoot("Projects/Core/NetworkCore")),
        .project(target: "OnboardingFeature", path: .relativeToRoot("Projects/Feature/OnboardingFeature")),
        .project(target: "FortuneFeature", path: .relativeToRoot("Projects/Feature/FortuneFeature")),
        .project(target: "TodakFeature", path: .relativeToRoot("Projects/Feature/TodakFeature")),
        .project(target: "LuckyActionFeature", path: .relativeToRoot("Projects/Feature/LuckyActionFeature")),
        .project(target: "MyPageFeature", path: .relativeToRoot("Projects/Feature/MyPageFeature"))
    ],
    hasTests: true
)
