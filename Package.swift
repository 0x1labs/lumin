// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Lumin",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Lumin", targets: ["Lumin"])
    ],
    targets: [
        .executableTarget(
            name: "Lumin",
            dependencies: [],
            path: "",
            exclude: [
                "LICENSE",
                "Info.plist",
                "Lumin.entitlements",
                "README.md",
                "run.sh",
                "Lumin.app",
                "build_dmg.sh",
                "Lumin.dmg"
            ],
            sources: ["LuminApp.swift", "Modules"],
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("ServiceManagement")
            ]
        )
    ]
)
