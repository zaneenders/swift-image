// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "swift-image",
  platforms: [.macOS(.v15)],
  products: [
    .executable(name: "swift-image", targets: ["SwiftImage"])
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", branch: "main")
  ],
  targets: [
    .executableTarget(
      name: "SwiftImage",
      dependencies: [
        .product(name: "Subprocess", package: "swift-subprocess")
      ])
  ]
)
