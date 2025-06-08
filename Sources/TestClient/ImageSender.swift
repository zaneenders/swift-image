import AsyncHTTPClient
import Foundation
import NIOCore
import _NIOFileSystem
import _NIOFileSystemFoundationCompat

@main
struct ImageSender {
  public static func main() async {
    guard let file = Bundle.module.url(forResource: "test", withExtension: "txt") else {
      print("Unable to laod file")
      return
    }
    do {
      let fp = FilePath(file.absoluteString.replacing("file:", with: ""))
      guard let buffer = try await fp._getBuffer()?.b64Decode() else {
        return
      }
      var request = HTTPClientRequest(url: "http://localhost:8080/image")
      request.method = .PUT
      request.body = .bytes(buffer)
      let response = try await HTTPClient.shared.execute(request, timeout: .seconds(3))
      print("HTTP status", response.status)
      let body = try await response.body.collect(upTo: .max)
      try await body.write(toFileAt: FilePath("out.jpg"))
    } catch {
      print(error)
    }
  }
}

extension ByteBuffer {
  func b64Decode() -> ByteBuffer? {
    guard let data = self.getData(at: 0, length: self.readableBytes, byteTransferStrategy: .automatic) else {
      print("Unable to read bytes")
      return nil
    }
    if let d = Data(base64Encoded: data) {
      return ByteBuffer(data: d)
    }
    return nil
  }
}

extension FilePath {
  fileprivate func _getBuffer() async throws -> ByteBuffer? {
    do {
      let fh = try await FileSystem.shared.openFile(forReadingAt: self)
      let buffer = try await fh.readToEnd(maximumSizeAllowed: .bytes(.max))
      try await fh.close()
      return buffer
    } catch {
      print(error)
      return nil
    }
  }
}
