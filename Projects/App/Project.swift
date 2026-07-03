import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeApp(
    name: "Todakun",
    dependencies: [
        .external(name: "ComposableArchitecture"),
        .project(target: "OnboardingFeature", path: .relativeToRoot("Projects/Feature/OnboardingFeature")),
        .project(target: "FortuneFeature", path: .relativeToRoot("Projects/Feature/FortuneFeature")),
        .project(target: "AssistantFeature", path: .relativeToRoot("Projects/Feature/AssistantFeature")),
        .project(target: "ActionFeature", path: .relativeToRoot("Projects/Feature/ActionFeature")),
        .project(target: "MyFeature", path: .relativeToRoot("Projects/Feature/MyFeature"))
    ]
)
