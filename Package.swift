// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "swift-byte-buffer",
    products: [
        .library(
            name: "ByteBuffer",
            targets: ["ByteBuffer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble", .upToNextMinor(from: "9.2.0"))
    ],
    targets: [
        .target(
            name: "ByteBuffer",
            dependencies: []),
        .testTarget(
            name: "ByteBufferTests",
            dependencies: ["ByteBuffer", "Nimble"]),
    ]
)
