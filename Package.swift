// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Snip",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Snip",
            path: "Snip"
        ),
        .testTarget(
            name: "SnipTests",
            dependencies: ["Snip"],
            path: "SnipTests"
        )
    ]
)
