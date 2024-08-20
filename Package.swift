// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.8"

let frameworks = ["ffmpegkit": "07cc1793f328d5aa598697754bf5532e4aa09198ba4bfbbdb93becdaf9aeb687", "libavcodec": "9319aa7ed157011b2291bac8d0c797e585103a2fd84fbcd6e97e0955af6ab2ae", "libavdevice": "c2a248b3bcab5331224b95a5bc363b5e28dd3cb95eebd225e1f1ebde9fd6f7b1", "libavfilter": "76349b63d08139f4cfe2cc8a8bdd62b9a899287ea20efee98e51c9648e6edc72", "libavformat": "a42dee2585d777052a5e4cea515fc5ec6e60c8ff54a90338bca0456902b68e56", "libavutil": "4aca1cc8c4dd780bbf7c47b9f1e2ac1c45bb3d4b0786004c9e4fe94254799b0b", "libswresample": "0cb58de56a72e7c6bcec6f207df22f588b47785d9393463147097ba3884d8ef2", "libswscale": "8a3d1c2e78db996af1e73a18361c4b20c93205249d44f6bf0b167578509d188f"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/tylerjonesio/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
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
