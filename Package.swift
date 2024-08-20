// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "5.2.0"

let frameworks = ["ffmpegkit": "1cb289aa6c194ee5d259a8f1fbcb27c4bd4babcd5272572cf0733c7aa574f231", "libavcodec": "47b1d68aab32b54c3c9d059d3ba118bba73501a0f5f74ce66481f7b2c249d0c8", "libavdevice": "e443f8254559c147cb1768faf3caeb54d1a679bdb1441f8c71289bce3ca2b4df", "libavfilter": "c9e39499fbdd8eb2067102be71469b718a51f9fcd33bf3daf45f05a614e27958", "libavformat": "df9cb990a7316c0a9bf959bb38ca8b5d474f109a5b3c81366bcd96e28673d48e", "libavutil": "e4bfe287c2409c280e96691169e8995c7aab4a2db3cfd9d586f3a8ccbb38ad83", "libswresample": "c0097172886e3fbe780ce49e7c689265531766a12f31c3d68cd137c994512a5b", "libswscale": "3fc43857bef5accee37b21ed3eb902f939666111007c69ecfb4a86dca199057a"]

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
