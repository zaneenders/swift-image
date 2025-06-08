import Foundation
import HTTPTypes
import Hummingbird
import NIOCore
import Subprocess

let fileNameHeader = HTTPField.Name("fileName")!

func buildServer() -> any ApplicationProtocol {
  let fileIO = FileIO()
  let router = Router()
  router.put("image") { request, context -> Response in
    // TODO don't assume png
    let fileName = "\(UUID())"
    let png = fileName + ".png"
    let jpg = fileName + ".jpg"
    do {
      try await fileIO.writeFile(contents: request.body, path: fileName, context: context)
      do {
        _ = try await run(
          .name("ffmpeg"), arguments: ["-i", png, jpg],
          output: .fileDescriptor(.standardOutput, closeAfterSpawningProcess: false),
          error: .fileDescriptor(.standardError, closeAfterSpawningProcess: false))
      } catch {
        return Response(status: .internalServerError, body: ResponseBody(byteBuffer: ByteBuffer(string: "\(error)")))
      }
      let body = try await fileIO.loadFile(path: fileName, context: context)
      let rsp = Response(status: .ok, headers: [fileNameHeader: fileName], body: body)
      // TODO delete file after send
      // Because we are using the system call to send the file we have to wait to clean up.
      context.logger.trace("file converted: \(fileName)")
      return rsp
    } catch {
      return Response(status: .badRequest)
    }
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
