import Foundation
import NIOCore
import Subprocess
import _NIOFileSystem
import _NIOFileSystemFoundationCompat

extension FilePath {
  func getBuffer() async throws -> ByteBuffer {
    let fh = try await FileSystem.shared.openFile(forReadingAt: self)
    let buffer = try await fh.readToEnd(maximumSizeAllowed: .bytes(.max))
    try await fh.close()
    return buffer
  }
}

@main
struct SwiftImage {
  static func main() async {
    let testPath = FilePath("Fixtures/test.txt")
    guard (try? await FileSystem.shared.info(forFileAt: testPath)) != nil else {
      print("missing file: \(testPath.string)")
      return
    }
    print(FileManager.default.fileExists(atPath: "Fixtures/test.txt"))
    let url: FilePath = "idk.png"
    do {
      let buffer = try await testPath.getBuffer()
      guard let data = buffer.getData(at: 0, length: buffer.readableBytes, byteTransferStrategy: .automatic) else {
        print("Unable to read bytes")
        return
      }
      if let d = Data(base64Encoded: data) {
        do {
          try await d.write(toFileAt: url, options: .newFile(replaceExisting: true))
          print("File created: \(url.string)")
        } catch {
          print(error)
        }
      }
    } catch {
      print(error)
      return
    }

    print(FileManager.default.fileExists(atPath: "idk.png"))
    print(FileManager.default.fileExists(atPath: "out.jpg"))
    do {
      _ = try await run(
        .name("ffmpeg"), arguments: ["-i", "idk.png", "out.jpg"],
        output: .fileDescriptor(.standardOutput, closeAfterSpawningProcess: false),
        error: .fileDescriptor(.standardError, closeAfterSpawningProcess: false))
    } catch {
      print(error)
    }
    print(FileManager.default.fileExists(atPath: "out.jpg"))
  }
}
