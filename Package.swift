// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "5.2.1"

let frameworks = ["ffmpegkit": "c0ec8f3706f6e8e92195a4fb8340218eda156f3c85d08585e91b349b7e4894a7", "libavcodec": "1b371fc404f7c3706adc97b46b8157d9493dfe12be1223f09709b7ce62d68d25", "libavdevice": "3209b1ae3ce044913456c75d0f2aa1d89709f13352d116e97e934a5dfd4dd636", "libavfilter": "2d63a3d6fcabacd3f0a376df66ec5c80c5de48adbd579d3381f15dbe7b37a237", "libavformat": "38c4dd51b1ed6b9a64e372e1cd65aa346133b3a094bbbf10a0bb3c98e1b7e5d1", "libavutil": "4b73153ff78e0d39a27c3dad98f3e0d5a0a7d65d502f5aa9316cb17f835352bd", "libswresample": "e8364b270fead28c0f50cbcdd97d8acdd33709968d74eb814d94844d0efe107f", "libswscale": "fce7af299a0fef3a6ac103f95fbd807e41575f1f66d105658e0ff085770ebc11"]

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
