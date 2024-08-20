// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.9"

let frameworks = ["ffmpegkit": "f05ccf3349f7bfc801cc1f9c1e8438231a9f89cc3cc0323194cfe3b3d3fca7ae", "libavcodec": "3db8b0b6c14fabe99a229c019f3f7fc11d6a3e96b9183a18c71760653013432d", "libavdevice": "de0bc6e83f544c01eb3cd3d5624c798c448c2ed97ad5d88c6e5476d2f9bafba5", "libavfilter": "8a142367ab54fbfbe89ef4e0f8e20503c4096f976634cfacc90a76aea53b8314", "libavformat": "68d0e56e4e76cfe0a79c3ca4ec3be19c0ce429b61e3b8ab70299112df14a8eac", "libavutil": "d5450a498576192316604838e7010715d9dc72ba5ad0446a734644621306e606", "libswresample": "e62b57c73640442ad84e0242c674346ec47271ca1bc39f966c8f521fb44d6ff6", "libswscale": "9106bf1435fc62cf8872c1cf18ddebcc7b1850330199a2fbaaa71029ad984433"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/ptrkstr/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let linkerSettings: [LinkerSetting] = [
    .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
    .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
    .linkedFramework("OpenGL", .when(platforms: [.macOS])),
    .linkedFramework("VideoToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedLibrary("z"),
    .linkedLibrary("lzma"),
    .linkedLibrary("bz2"),
    .linkedLibrary("iconv")
]

let libAVFrameworks = frameworks.filter({ $0.key != "ffmpegkit" })

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "FFmpeg-Kit",
            type: .dynamic,
            targets: ["FFmpeg-Kit", "ffmpegkit"]),
        .library(
            name: "FFmpeg",
            type: .dynamic,
            targets: ["FFmpeg"] + libAVFrameworks.map { $0.key }),
    ] + libAVFrameworks.map { .library(name: $0.key, targets: [$0.key]) },
    dependencies: [],
    targets: [
        .target(
            name: "FFmpeg-Kit",
            dependencies: frameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
    ] + frameworks.map { xcframework($0) }
)
