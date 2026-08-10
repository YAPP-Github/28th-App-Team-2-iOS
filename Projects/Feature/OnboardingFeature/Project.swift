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
    resources: ["Resources/**"],
    hasExample: true,
    exampleInfoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "토닥운",
        "UILaunchScreen": [:]
    ])
)
