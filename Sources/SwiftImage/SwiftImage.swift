import Subprocess

@main
struct SwiftImage {
  static func main() async {
    _ = try? await run(
      .name("ffmpeg"), arguments: ["-version"],
      output: .fileDescriptor(.standardOutput, closeAfterSpawningProcess: false),
      error: .fileDescriptor(.standardError, closeAfterSpawningProcess: false))
  }
}
