// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.7"

let frameworks = ["ffmpegkit": "98fdbd69e25601300ac22a0f593ff78265b8906f386db8fb45e0d81d8d192983", "libavcodec": "793cffaf2aaeb488fd7459c554d9522b0b556498a9855dc22517c02d526e9945", "libavdevice": "2da306c28dc66565dde0dd42fee9d978be43ff2187ed0d18a9a7b13c5e31af44", "libavfilter": "74dd1bba18a9aef6b8106e795e9eba6838d0db5219de58b4566b7a3a9aeb45cb", "libavformat": "ffe20f947dbd9e9e65997807f583691d21df62f544fa5c18fe348018fb308b6f", "libavutil": "af59bdb8813e14ceb4a36a9f1621c9bbbada40a8c2a33785498f14d78359e151", "libswresample": "e384226175866aca5e89c6af6ba6fd606dac2ec4dd3d6195f9bb27845470ca58", "libswscale": "b41a4434090fcb051393c92d6ae782e7c8fdd8bf9c9aa531a0d2c8175c4cf3e3"]

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
