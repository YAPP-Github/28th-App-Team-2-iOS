import ProjectDescription

public extension Project {
    private static func makeModule(
        name: String,
        destinations: Destinations = .iOS,
        product: Product,
        bundleId: String? = nil,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        hasTests: Bool = true,
        hasDemo: Bool = false
    ) -> Project {
        
        let targetBundleId = bundleId ?? "com.kikidan.todakun.\(name)"
        var targets: [Target] = []
        
        // Main Target
        targets.append(
            .target(
                name: name,
                destinations: destinations,
                product: product,
                bundleId: targetBundleId,
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
                    bundleId: "\(targetBundleId)Tests",
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
                    bundleId: "\(targetBundleId)Demo",
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
        
        return Project(
            name: name,
            targets: targets
        )
    }
    
    public static func makeApp(
        name: String,
        bundleId: String = "com.kikidan.todakun",
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = ["Resources/**"]
    ) -> Project {
        return makeModule(
            name: name,
            product: .app,
            bundleId: bundleId,
            dependencies: dependencies,
            resources: resources,
            hasTests: false,
            hasDemo: false
        )
    }

    public static func makeFeature(
        name: String,
        dependencies: [TargetDependency] = [],
        hasInterface: Bool = true,
        hasDemo: Bool = true
    ) -> Project {
        let targetBundleId = "com.kikidan.todakun.\(name)"
        var targets: [Target] = []
        
        // 1. Interface Target
        let interfaceName = "\(name)Interface"
        targets.append(
            .target(
                name: interfaceName,
                destinations: .iOS,
                product: .staticFramework,
                bundleId: "\(targetBundleId)Interface",
                deploymentTargets: .iOS("17.0"),
                infoPlist: .default,
                sources: ["Interface/Sources/**"],
                dependencies: [] // Interface는 가능한 의존성을 최소화
            )
        )
        
        // 2. Implementation Target
        let defaultDependencies: [TargetDependency] = [
            .target(name: interfaceName),
            .project(target: "DesignSystem", path: .relativeToRoot("Projects/Core/DesignSystem")),
            .project(target: "NetworkCore", path: .relativeToRoot("Projects/Core/NetworkCore")),
            .project(target: "Model", path: .relativeToRoot("Projects/Core/Model")),
            .project(target: "Utils", path: .relativeToRoot("Projects/Core/Utils")),
            .external(name: "ComposableArchitecture")
        ]
        
        targets.append(
            .target(
                name: name,
                destinations: .iOS,
                product: .staticFramework,
                bundleId: targetBundleId,
                deploymentTargets: .iOS("17.0"),
                infoPlist: .default,
                sources: ["Sources/**"],
                dependencies: defaultDependencies + dependencies
            )
        )
        
        // 3. Tests Target
        targets.append(
            .target(
                name: "\(name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "\(targetBundleId)Tests",
                deploymentTargets: .iOS("17.0"),
                infoPlist: .default,
                sources: ["Tests/**"],
                dependencies: [.target(name: name)]
            )
        )
        
        // 4. Demo Target
        if hasDemo {
            targets.append(
                .target(
                    name: "\(name)Demo",
                    destinations: .iOS,
                    product: .app,
                    bundleId: "\(targetBundleId)Demo",
                    deploymentTargets: .iOS("17.0"),
                    infoPlist: .default,
                    sources: ["Demo/Sources/**"],
                    resources: ["Demo/Resources/**"],
                    dependencies: [.target(name: name)]
                )
            )
        }
        
        return Project(name: name, targets: targets)
    }

    public static func makeCore(
        name: String,
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = nil,
        hasTests: Bool = true
    ) -> Project {
        return makeModule(
            name: name,
            product: .staticFramework,
            dependencies: dependencies,
            resources: resources,
            hasTests: hasTests,
            hasDemo: false
        )
    }
}
