import Hummingbird
import HummingbirdTesting
import Testing

@testable import SwiftImage

@Suite
struct SwiftImageTests {
  @Test func hello() async throws {
    let server = buildServer()
    try await server.test(.router) { client in
      let rsp = try await client.execute(uri: "hello", method: .get)
      try #require(rsp.status == .ok)
      #expect(String(buffer: rsp.body) == "Hello")
    }
  }
}
