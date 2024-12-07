// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "SwiftOrg",
  products: [
    .library(name: "SwiftOrg", targets: ["SwiftOrg"]),
  ],
  targets: [
    .target(name: "SwiftOrg"),
    .testTarget(name: "SwiftOrgTests", dependencies: ["SwiftOrg"]),
  ]
)
