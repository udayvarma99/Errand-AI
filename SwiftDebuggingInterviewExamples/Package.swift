// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftDebuggingInterviewExamples",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "DebugExamples", targets: ["DebugExamples"]),
        .executable(name: "Runner", targets: ["Runner"])
    ],
    targets: [
        .target(
            name: "DebugExamples",
            dependencies: []
        ),
        .executableTarget(
            name: "Runner",
            dependencies: ["DebugExamples"]
        ),
        .testTarget(
            name: "DebugExamplesTests",
            dependencies: ["DebugExamples"]
        )
    ]
)

