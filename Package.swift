// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ScrollCounter",

    products: [
        .library(
            name: "ScrollCounter",
            targets: ["ScrollCounter"]),
    ],

    targets: [
        .target(
            name: "ScrollCounter",
            path: "ScrollCounter")
    ]
)