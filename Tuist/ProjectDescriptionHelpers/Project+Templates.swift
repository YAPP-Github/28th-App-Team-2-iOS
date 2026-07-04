import ProjectDescription

public extension Project {
    private static let bundleIdPrefix = "com.kikidan.todakun"
    
    private static func makeTargets(
        name: String,
        destinations: Destinations = .iOS,
        product: Product,
        bundleId: String,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        hasTests: Bool = true,
        hasDemo: Bool = false
    ) -> [Target] {
        var targets: [Target] = []
        
        // Main Target
        targets.append(
            .target(
                name: name,
                destinations: destinations,
                product: product,
                bundleId: bundleId,
                deploymentTargets: deploymentTargets,
                infoPlist: .default,
                sources: sources,
                resources: resources,
                dependencies: dependencies
            )
        )
        
        // Unit Tests Target
        if hasTests {
            targets.append(
                .target(
                    name: "\(name)Tests",
                    destinations: destinations,
                    product: .unitTests,
                    bundleId: "\(bundleId)Tests",
                    deploymentTargets: deploymentTargets,
                    infoPlist: .default,
                    sources: ["Tests/**"],
                    dependencies: [
                        .target(name: name)
                    ]
                )
            )
        }
        
        // Demo App Target
        if hasDemo {
            targets.append(
                .target(
                    name: "\(name)Demo",
                    destinations: destinations,
                    product: .app,
                    bundleId: "\(bundleId)Demo",
                    deploymentTargets: deploymentTargets,
                    infoPlist: .default,
                    sources: ["Demo/Sources/**"],
                    resources: ["Demo/Resources/**"],
                    dependencies: [
                        .target(name: name)
                    ]
                )
            )
        }
        
        return targets
    }
    
    static func makeApp(
        name: String,
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = ["Resources/**"]
    ) -> Project {
        let targets = makeTargets(
            name: name,
            product: .app,
            bundleId: bundleIdPrefix,
            dependencies: dependencies,
            resources: resources,
            hasTests: false,
            hasDemo: false
        )
        return Project(name: name, targets: targets)
    }

    static func makeFeature(
        name: String,
        dependencies: [TargetDependency] = [],
        hasDemo: Bool = true
    ) -> Project {
        let targetBundleId = "\(bundleIdPrefix).\(name)"
        
        // 1. Interface Target
        let interfaceName = "\(name)Interface"
        let interfaceTargets = makeTargets(
            name: interfaceName,
            product: .staticFramework,
            bundleId: "\(targetBundleId)Interface",
            sources: ["Interface/Sources/**"],
            hasTests: false,
            hasDemo: false
        )
        
        // 2. Implementation + Tests + Demo
        let defaultDependencies: [TargetDependency] = [
            .target(name: interfaceName),
            .project(target: "DesignSystem", path: .relativeToRoot("Projects/Core/DesignSystem")),
            .project(target: "NetworkCore", path: .relativeToRoot("Projects/Core/NetworkCore")),
            .project(target: "Model", path: .relativeToRoot("Projects/Core/Model")),
            .project(target: "Utils", path: .relativeToRoot("Projects/Core/Utils")),
            .external(name: "ComposableArchitecture")
        ]
        
        let implementationTargets = makeTargets(
            name: name,
            product: .staticFramework,
            bundleId: targetBundleId,
            dependencies: defaultDependencies + dependencies,
            hasDemo: hasDemo
        )
        
        return Project(name: name, targets: interfaceTargets + implementationTargets)
    }

    static func makeCore(
        name: String,
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = nil,
        hasTests: Bool = true
    ) -> Project {
        let targets = makeTargets(
            name: name,
            product: .staticFramework,
            bundleId: "\(bundleIdPrefix).\(name)",
            dependencies: dependencies,
            resources: resources,
            hasTests: hasTests
        )
        return Project(name: name, targets: targets)
    }
}
