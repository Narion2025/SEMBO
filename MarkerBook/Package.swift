// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkerBook",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MarkerBook",
            targets: ["MarkerBook"]
        )
    ],
    dependencies: [
        // YAML Parser für Import/Export
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        // SwiftLint für Code-Qualität
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0")
    ],
    targets: [
        .executableTarget(
            name: "MarkerBook",
            dependencies: ["Yams"],
            path: "Sources"
        ),
        .testTarget(
            name: "MarkerBookTests",
            dependencies: ["MarkerBook"],
            path: "Tests/UnitTests"
        )
    ]
) 