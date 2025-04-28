# M.A.V.I.S - My Average Very Intelligent System
A proof of concept on the IOS platform.

---

## XCFramework
The XCFramework is a precompiled version of the library for iOS, visionOS, tvOS,
and macOS. It can be used in Swift projects without the need to compile the
library from source. For examples:
```swift
// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Whisper",
    targets: [
        .executableTarget(
            name: "Whisper",
            dependencies: [
                "WhisperFramework"
            ]),
        .binaryTarget(
            name: "WhisperFramework",
            url: "https://github.com/ggml-org/whisper.cpp/releases/download/v1.7.5/whisper-v1.7.5-xcframework.zip",
            checksum: "c7faeb328620d6012e130f3d705c51a6ea6c995605f2df50f6e1ad68c59c6c4a"
        )
    ]
)
```

| Example                                             | Web                                   | Description                                                                                                                     |
| --------------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| [whisper-cli](examples/cli)                         | [whisper.wasm](examples/whisper.wasm) | Tool for translating and transcribing audio using Whisper                                                                       |
| [whisper-bench](examples/bench)                     | [bench.wasm](examples/bench.wasm)     | Benchmark the performance of Whisper on your machine                                                                            |
| [whisper-stream](examples/stream)                   | [stream.wasm](examples/stream.wasm)   | Real-time transcription of raw microphone capture                                                                               |
| [whisper-command](examples/command)                 | [command.wasm](examples/command.wasm) | Basic voice assistant example for receiving voice commands from the mic                                                         |
| [whisper-server](examples/server)                   |                                       | HTTP transcription server with OAI-like API                                                                                     |
| [whisper-talk-llama](examples/talk-llama)           |                                       | Talk with a LLaMA bot                                                                                                           |
| [whisper.objc](examples/whisper.objc)               |                                       | iOS mobile application using whisper.cpp                                                                                        |
| [whisper.swiftui](examples/whisper.swiftui)         |                                       | SwiftUI iOS / macOS application using whisper.cpp                                                                               |
| [whisper.android](examples/whisper.android)         |                                       | Android mobile application using whisper.cpp                                                                                    |
| [whisper.nvim](examples/whisper.nvim)               |                                       | Speech-to-text plugin for Neovim                                                                                                |
| [generate-karaoke.sh](examples/generate-karaoke.sh) |                                       | Helper script to easily [generate a karaoke video](https://youtu.be/uj7hVta4blM) of raw audio capture                           |
| [livestream.sh](examples/livestream.sh)             |                                       | [Livestream audio transcription](https://github.com/ggml-org/whisper.cpp/issues/185)                                            |
| [yt-wsp.sh](examples/yt-wsp.sh)                     |                                       | Download + transcribe and/or translate any VOD [(original)](https://gist.github.com/DaniruKun/96f763ec1a037cc92fe1a059b643b818) |
| [wchess](examples/wchess)                           | [wchess.wasm](examples/wchess)        | Voice-controlled chess                                                              
