import ProjectDescription

let workspace = Workspace(
    name: "todakun",
    projects: [
        "Projects/App",
        "Projects/Feature/**",
        "Projects/Core/**"
    ]
)
