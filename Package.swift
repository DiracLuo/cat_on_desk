// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PetCompanion",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PetCompanion", targets: ["PetCompanion"])
    ],
    targets: [
        .executableTarget(
            name: "PetCompanion",
            path: "Sources/PetCompanion"
        )
    ]
)
