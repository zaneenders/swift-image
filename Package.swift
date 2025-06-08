// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "swift-image",
  platforms: [.macOS(.v15)],
  products: [
    .executable(name: "swift-image", targets: ["SwiftImage"])
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", branch: "main"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.83.0"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "SwiftImage",
      dependencies: [
        .product(name: "Subprocess", package: "swift-subprocess"),
        .product(name: "_NIOFileSystem", package: "swift-nio"),
        .product(name: "_NIOFileSystemFoundationCompat", package: "swift-nio"),
        .product(name: "Hummingbird", package: "hummingbird"),
      ],
    ),
    .testTarget(
      name: "SwiftImageTests",
      dependencies: [
        "SwiftImage",
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdTesting", package: "hummingbird"),
      ],
      resources: [
        .process("Resources")
      ]
    ),
  ]
)
