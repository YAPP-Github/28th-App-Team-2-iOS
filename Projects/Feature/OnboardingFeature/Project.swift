import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeFeature(
    name: "OnboardingFeature",
    dependencies: [
        .external(name: "GoogleSignIn"),
        .external(name: "KakaoSDKAuth"),
        .external(name: "KakaoSDKCommon"),
        .external(name: "KakaoSDKUser")
    ],
    hasExample: false
)
