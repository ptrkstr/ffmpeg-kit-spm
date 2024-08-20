// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.8"

let frameworks = ["ffmpegkit": "cdff2ac486d19cfefcab8665f615d5b7dc4a3781906862a3e7f53cfbe785774f", "libavcodec": "543ac08fc96780086759103eeeb5831de777aaa987772b30647ab51d3dc4acd7", "libavdevice": "f9246b7a67c26438f3fe85741b668f35d8f8e412d7e44167f517ac88bbb1b109", "libavfilter": "3613fbea4df489e1a23dca7ad527b566c1d59aad95c56ca7f988284aade0db09", "libavformat": "d2c98c32840ae65e1719b0514bc6ac31fe78c715dd866354fcd1bce4ed9a1b3d", "libavutil": "764abd515a78154e4cd574ef53ded47f2d86b79acac6a679204b82ea740358e6", "libswresample": "b7ae4569f68bc68db29c850783a47ff200b8a565c7652059779b84a2b2cda5c3", "libswscale": "31be2e03669d4f9d8661d4d0eaf1c89f0f49087d43a040f3ed396dde3add7ece"]

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
