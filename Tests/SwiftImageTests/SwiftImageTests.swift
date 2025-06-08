import Foundation
import Hummingbird
import HummingbirdTesting
import Testing
import _NIOFileSystem

@testable import SwiftImage
@testable import TestClient

@Suite
struct SwiftImageTests {
  @Test func convert() async throws {
    guard let file = Bundle.module.url(forResource: "test", withExtension: "txt") else {
      Issue.record("Unable to laod file")
      return
    }
    let fp = FilePath(file.absoluteString.replacing("file:", with: ""))
    let fh = try await FileSystem.shared.openFile(forReadingAt: fp)
    guard let buffer = try await fh.readToEnd(maximumSizeAllowed: .bytes(.max)).b64Decode() else {
      Issue.record("Unable to decode file")
      try await fh.close()
      return
    }
    try await fh.close()
    let server = buildServer()
    try await server.test(.router) { client in
      let rsp = try await client.execute(uri: "image", method: .put, body: buffer)
      try #require(rsp.status == .internalServerError)
      // Header only return when ffmpeg is avaiable
      /*
        guard let fileName = rsp.headers[fileNameHeader] else {
          Issue.record("Missing header")
          return
        }
      */
      let err = String(buffer: rsp.body)
      #expect(err == "Executable \"ffmpeg\" is not found or cannot be executed.")
    }
  }
}
