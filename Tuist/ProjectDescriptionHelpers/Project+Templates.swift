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
        exampleDependencies: [TargetDependency] = [],
        exampleInfoPlist: InfoPlist? = nil
    ) -> [Target] {
        var targets: [Target] = []

        // Product가 .app일 때는 전체 화면 구동을 위해 UILaunchScreen 키 주입
        let mainInfoPlist: InfoPlist = (product == .app) ? .extendingDefault(with: [
            "UILaunchScreen": [:]
        ]) : .default

        // Main Target
        targets.append(
            .target(
                name: name,
                destinations: destinations,
                product: product,
                bundleId: bundleId,
                deploymentTargets: deploymentTargets,
                infoPlist: mainInfoPlist,
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
                    infoPlist: exampleInfoPlist ?? .extendingDefault(with: [
                        "UILaunchScreen": [:]
                    ]),
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
        resources: ResourceFileElements? = ["Resources/**"],
        hasTests: Bool = false
    ) -> Project {
        var targets = [
            Target.target(
                name: name,
                destinations: .iOS,
                product: .app,
                bundleId: bundleIdPrefix,
                deploymentTargets: .iOS("17.0"),
                infoPlist: .extendingDefault(with: [
                    "CFBundleDisplayName": "토닥운",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "LSApplicationCategoryType": "public.app-category.lifestyle",
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIUserInterfaceStyle": "Light",
                    "API_BASE_URL": "$(API_BASE_URL)",
                    "GOOGLE_IOS_CLIENT_ID": "$(GOOGLE_IOS_CLIENT_ID)",
                    "KAKAO_NATIVE_APP_KEY": "$(KAKAO_NATIVE_APP_KEY)",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLSchemes": [
                                "$(GOOGLE_REVERSED_CLIENT_ID)",
                                "kakao$(KAKAO_NATIVE_APP_KEY)"
                            ]
                        ]
                    ]
                ]),
                sources: ["Sources/**"],
                resources: resources,
                dependencies: dependencies,
                settings: .settings(
                    base: [
                        // GoogleSignIn의 AppAuth는 Objective-C category로 iOS authorization
                        // presenter를 제공합니다. 정적 링크 시 category object가 제거되지 않도록 합니다.
                        "OTHER_LDFLAGS": "$(inherited) -ObjC",
                        "MARKETING_VERSION": "1.0.0",
                        "CURRENT_PROJECT_VERSION": "1.0.0"
                    ],
                    configurations: [
                        .debug(
                            name: "Debug",
                            settings: [
                                "CODE_SIGN_ENTITLEMENTS": "Todakun-Debug.entitlements"
                            ],
                            xcconfig: .relativeToRoot("Configuration/Debug.xcconfig")
                        ),
                        .release(
                            name: "Release",
                            settings: [
                                "CODE_SIGN_ENTITLEMENTS": "Todakun-Release.entitlements"
                            ],
                            xcconfig: .relativeToRoot("Configuration/Release.xcconfig")
                        )
                    ]
                )
            )
        ]

        if hasTests {
            targets.append(
                .target(
                    name: "\(name)Tests",
                    destinations: .iOS,
                    product: .unitTests,
                    bundleId: "\(bundleIdPrefix).Tests",
                    deploymentTargets: .iOS("17.0"),
                    infoPlist: .default,
                    sources: ["Tests/**"],
                    dependencies: [.target(name: name)]
                )
            )
        }

        return Project(name: name, targets: targets)
    }

    static func makeFeature(
        name: String,
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = nil,
        hasTesting: Bool = true,
        hasExample: Bool = true,
        exampleInfoPlist: InfoPlist? = nil
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
            .project(target: "AuthSession", path: .relativeToRoot("Projects/Core/AuthSession")),
            .project(target: "Model", path: .relativeToRoot("Projects/Core/Model")),
            .project(target: "Utils", path: .relativeToRoot("Projects/Core/Utils")),
            .external(name: "ComposableArchitecture")
        ]

        let implementationTargets = makeTargets(
            name: name,
            product: .staticFramework,
            bundleId: targetBundleId,
            dependencies: defaultDependencies + dependencies,
            resources: resources,
            hasTests: true,
            testDependencies: testDependencies,
            hasExample: hasExample,
            exampleDependencies: exampleDependencies,
            exampleInfoPlist: exampleInfoPlist
        )
        projectTargets.append(contentsOf: implementationTargets)

        var schemes: [Scheme] = [
            .scheme(
                name: name,
                shared: true,
                buildAction: .buildAction(targets: [.target(name)]),
                testAction: .targets([.testableTarget(target: .target("\(name)Tests"))])
            )
        ]

        if hasExample {
            schemes.append(
                .scheme(
                    name: "\(name)Example",
                    shared: true,
                    buildAction: .buildAction(targets: [.target("\(name)Example")]),
                    runAction: .runAction(executable: .target("\(name)Example"))
                )
            )
        }

        return Project(
            name: name,
            options: .options(automaticSchemesOptions: .disabled),
            targets: projectTargets,
            schemes: schemes
        )
    }

    static func makeCore(
        name: String,
        dependencies: [TargetDependency] = [],
        resources: ResourceFileElements? = nil,
        hasTests: Bool = true,
        testDependencies: [TargetDependency] = [],
        hasExample: Bool = false
    ) -> Project {
        let targets = makeTargets(
            name: name,
            product: .staticFramework,
            bundleId: "\(bundleIdPrefix).\(name)",
            dependencies: dependencies,
            resources: resources,
            hasTests: hasTests,
            testDependencies: testDependencies,
            hasExample: hasExample
        )

        var schemes: [Scheme] = [
            .scheme(
                name: name,
                shared: true,
                buildAction: .buildAction(targets: [.target(name)]),
                testAction: hasTests ? .targets([.testableTarget(target: .target("\(name)Tests"))]) : nil
            )
        ]

        if hasExample {
            schemes.append(
                .scheme(
                    name: "\(name)Example",
                    shared: true,
                    buildAction: .buildAction(targets: [.target("\(name)Example")]),
                    runAction: .runAction(executable: .target("\(name)Example"))
                )
            )
        }

        return Project(
            name: name,
            options: .options(automaticSchemesOptions: .disabled),
            targets: targets,
            schemes: schemes
        )
    }
}
