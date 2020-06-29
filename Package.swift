// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ls2xsR",
    products: [
        .executable(name: "ls2xsR", targets: ["ls2xsR"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "ls2xsR",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "ls2xsRTests",
            dependencies: ["ls2xsR"]),
    ]
)

// Local Variables:
// swift-mode:parenthesized-expression-offset: 4
// End:
