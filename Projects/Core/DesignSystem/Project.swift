import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeCore(
    name: "DesignSystem",
    dependencies: [
        .project(
            target: "Model",
            path: .relativeToRoot("Projects/Core/Model")
        )
    ],
    resources: ["Resources/**"],
    hasExample: true
)
