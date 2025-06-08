import Foundation
import Hummingbird
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

  func decodeImageFile(to name: String) async -> FilePath? {
    guard (try? await FileSystem.shared.info(forFileAt: self)) != nil else {
      print("missing file: \(self.string)")
      return nil
    }
    guard let buffer = try? await self.getBuffer() else {
      print("unable to get buffer")
      return nil
    }
    guard let data = buffer.getData(at: 0, length: buffer.readableBytes, byteTransferStrategy: .automatic) else {
      print("Unable to read bytes")
      return nil
    }

    let out = FilePath(name)
    if let d = Data(base64Encoded: data) {
      do {
        try await d.write(toFileAt: out, options: .newFile(replaceExisting: true))
        return out
      } catch {
        print(error)
      }
    }
    return nil
  }
}

func ffmpeg() async {
  let testPath = FilePath("Fixtures/test.txt")
  print(FileManager.default.fileExists(atPath: "Fixtures/test.txt"))
  do {
    let png = "idk.png"
    let jpg = "out.jpg"
    guard await testPath.decodeImageFile(to: png) != nil else {
      print("Error decoding file \(testPath.string)")
      return
    }
    print(FileManager.default.fileExists(atPath: png))
    print(FileManager.default.fileExists(atPath: jpg))
    _ = try await run(
      .name("ffmpeg"), arguments: ["-i", png, jpg],
      output: .fileDescriptor(.standardOutput, closeAfterSpawningProcess: false),
      error: .fileDescriptor(.standardError, closeAfterSpawningProcess: false))
    print(FileManager.default.fileExists(atPath: "out.jpg"))
  } catch {
    print(error)
    return
  }
}

func buildServer() -> any ApplicationProtocol {
  let router = Router()
  router.get("hello") { request, context -> Response in
    return Response(status: .ok, body: ResponseBody(byteBuffer: ByteBuffer(string: "Hello")))
  }
  let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
  )
  return app
}

@main
struct SwiftImage {
  static func main() async {
    let server = buildServer()
    do {
      try await server.runService()
    } catch {
      print(error)
    }
  }
}
