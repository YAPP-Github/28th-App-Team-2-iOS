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
        testDependencies: [TargetDependency] = [],
        hasExample: Bool = false,
        exampleDependencies: [TargetDependency] = []
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
                    ] + testDependencies
                )
            )
        }
        
        // Example App Target
        if hasExample {
            targets.append(
                .target(
                    name: "\(name)Example",
                    destinations: destinations,
                    product: .app,
                    bundleId: "\(bundleId)Example",
                    deploymentTargets: deploymentTargets,
                    infoPlist: .default,
                    sources: ["Example/Sources/**"],
                    resources: ["Example/Resources/**"],
                    dependencies: [
                        .target(name: name)
                    ] + exampleDependencies
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
            hasExample: false
        )
        return Project(name: name, targets: targets)
    }

    static func makeFeature(
        name: String,
        dependencies: [TargetDependency] = [],
        hasTesting: Bool = true,
        hasExample: Bool = true
    ) -> Project {
        let targetBundleId = "\(bundleIdPrefix).\(name)"
        var projectTargets: [Target] = []
        
        // 1. Interface Target
        let interfaceName = "\(name)Interface"
        let interfaceTargets = makeTargets(
            name: interfaceName,
            product: .staticFramework,
            bundleId: "\(targetBundleId)Interface",
            sources: ["Interface/Sources/**"],
            hasTests: false,
            hasExample: false
        )
        projectTargets.append(contentsOf: interfaceTargets)
        
        // 2. Testing Target (Optional)
        var testDependencies: [TargetDependency] = []
        var exampleDependencies: [TargetDependency] = []
        
        if hasTesting {
            let testingName = "\(name)Testing"
            let testingTargets = makeTargets(
                name: testingName,
                product: .staticFramework,
                bundleId: "\(targetBundleId)Testing",
                dependencies: [
                    .target(name: interfaceName),
                    .project(target: "Model", path: .relativeToRoot("Projects/Core/Model")),
                    .project(target: "Utils", path: .relativeToRoot("Projects/Core/Utils")),
                    .external(name: "ComposableArchitecture")
                ],
                sources: ["Testing/Sources/**"],
                hasTests: false,
                hasExample: false
            )
            projectTargets.append(contentsOf: testingTargets)
            testDependencies.append(.target(name: testingName))
            exampleDependencies.append(.target(name: testingName))
        }
        
        // 3. Implementation + Tests + Example
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
            hasTests: true,
            testDependencies: testDependencies,
            hasExample: hasExample,
            exampleDependencies: exampleDependencies
        )
        projectTargets.append(contentsOf: implementationTargets)
        
        return Project(name: name, targets: projectTargets)
    }

    static func makeCore(
        name: String,
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = nil,
        hasTests: Bool = true,
        hasExample: Bool = false,
        exampleDependencies: [TargetDependency] = []
    ) -> Project {
        let targets = makeTargets(
            name: name,
            product: .staticFramework,
            bundleId: "\(bundleIdPrefix).\(name)",
            dependencies: dependencies,
            resources: resources,
            hasTests: hasTests,
            hasExample: hasExample,
            exampleDependencies: exampleDependencies
        )
        return Project(name: name, targets: targets)
    }
}
