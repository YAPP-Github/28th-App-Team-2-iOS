import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeCore(
    name: "AuthSession",
    dependencies: [
        .external(name: "ComposableArchitecture")
    ]
)
