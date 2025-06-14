// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "SwiftOrg",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(name: "SwiftOrg", targets: ["SwiftOrg"])
  ],
  targets: [
    .target(
      name: "SwiftOrg"
    ),
    .testTarget(
      name: "SwiftOrgTests",
      dependencies: ["SwiftOrg"]
    ),
  ]
)
