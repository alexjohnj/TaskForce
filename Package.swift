// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "TaskForce",
  products: [
    .library(name: "TaskForce", targets: ["TaskForce"])
  ],
  targets: [
    .target(name: "TaskForce", path: "Sources/"),
    .testTarget(name: "TaskForceTests", dependencies: ["TaskForce"], path: "Tests/")
  ]
)
