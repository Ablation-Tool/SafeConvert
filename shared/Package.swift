// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SafeConvertCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "SafeConvertCore", targets: ["SafeConvertCore"])],
    targets: [
        .target(name: "SafeConvertCore", path: "Sources/SafeConvertCore"),
        .testTarget(name: "SafeConvertCoreTests", dependencies: ["SafeConvertCore"], path: "Tests/SafeConvertCoreTests")
    ]
)
