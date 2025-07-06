// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BrightMultiDisplay",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "BrightMultiDisplay",
            dependencies: ["KeyboardShortcuts"],
            path: "Sources/BrightMultiDisplay"
        )
    ]
)
