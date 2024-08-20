// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.8"

let frameworks = ["ffmpegkit": "a080f8953ad48e1f00adcecfa7188b23ec45bdd41ab8ca9c1399d14100d896bc", "libavcodec": "99bbb8d91b9106e9abefa3feb523eaa6394b51a389782cb64dcea24c6151e676", "libavdevice": "b1d06a3806422ded68f4b88886cd80fba6dc27a060efe696704fbff1f7dc9207", "libavfilter": "f2fa80a201adcacfa7c1d1923f74393b24b47b97889f28069cfb54fca8cb56f8", "libavformat": "51087c4d0202eeef4004c17efbd21968b3040422bbe29d8a7444005cb9365ea7", "libavutil": "2d88085e0107f16353c20616fc6ff4a0e41d3cb7cb6391a658f6bfcae65f1f90", "libswresample": "321549a1b7333c0cb67f4286874abfb489becb5c049d33c1437047b74d31939c", "libswscale": "95fb8b210c055eae5ee7c6c14d9d3e88662b091127c75ac665080f23aeb66aa4"]

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
