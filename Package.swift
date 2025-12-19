// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CleanCopy",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CleanCopy",
            path: "CleanCopy"
        ),
        .testTarget(
            name: "CleanCopyTests",
            dependencies: ["CleanCopy"],
            path: "CleanCopyTests"
        )
    ]
)
