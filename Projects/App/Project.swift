import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeApp(
    name: "Todakun",
    dependencies: [
        .external(name: "ComposableArchitecture"),
        .project(target: "OnboardingFeature", path: .relativeToRoot("Projects/Feature/OnboardingFeature")),
        .project(target: "FortuneFeature", path: .relativeToRoot("Projects/Feature/FortuneFeature")),
        .project(target: "TodakFeature", path: .relativeToRoot("Projects/Feature/TodakFeature")),
        .project(target: "LuckyActionFeature", path: .relativeToRoot("Projects/Feature/LuckyActionFeature")),
        .project(target: "MyPageFeature", path: .relativeToRoot("Projects/Feature/MyPageFeature"))
    ]
)
