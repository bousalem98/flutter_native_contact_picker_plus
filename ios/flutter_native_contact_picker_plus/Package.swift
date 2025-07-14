// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_native_contact_picker_plus",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14"),
    ],
    products: [
        .library(
            name: "flutter-native-contact-picker-plus",
            targets: ["flutter_native_contact_picker_plus"]
        )
    ],
    targets: [
        .target(
            name: "ObjCPart",
            path: "Sources/ObjCPart",
            publicHeadersPath: "."
        ),
        .target(
            name: "flutter_native_contact_picker_plus",
            dependencies: ["ObjCPart"],
            path: "Sources/flutter_native_contact_picker_plus",
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            swiftSettings: [
                .unsafeFlags(["-import-objc-header", "include/FlutterNativeContactPickerPlus-Bridging-Header.h"])
            ]
        )
    ]
)
