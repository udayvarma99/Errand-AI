// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftDebuggingExamples",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SwiftDebuggingExamples",
            targets: ["SwiftDebuggingExamples"]
        ),
        .executable(
            name: "SwiftDebuggingExamplesCLI",
            targets: ["SwiftDebuggingExamplesCLI"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftDebuggingExamples",
            dependencies: []
        ),
        .executableTarget(
            name: "SwiftDebuggingExamplesCLI",
            dependencies: ["SwiftDebuggingExamples"]
        ),
        .testTarget(
            name: "SwiftDebuggingExamplesTests",
            dependencies: ["SwiftDebuggingExamples"]
        ),
    ]
)
