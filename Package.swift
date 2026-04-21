// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "AdhkarCounter",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "AdhkarCounter", targets: ["AdhkarCounter"])
    ],
    targets: [
        .executableTarget(
            name: "AdhkarCounter",
            path: "Sources"
        )
    ]
)
