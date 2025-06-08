# SwiftImage

This provides a basic [Hummingbird](https://hummingbird.codes) server over 
[ffmpeg](https://www.ffmpeg.org). Currently supports receiving `.png` files and
converting them to jpg.

See the [ImageSender.swift](./Sources/TestClient/ImageSender.swift) file for an
example client use of the server.

## Docker

Sets up a Linux image with `ffmpeg` installed.

### Build

```
docker build -t swift-image:latest .
```

### Run

```
docker run swift-image:latest
```

## possible Improvements

⚠️This is very incomplete and many improvements can be made.

- [ ] Don’t assume host `0.0.0.0` and port `8080`
- [ ] Support more then `.png` input file types, maybe by passing type in the 
  header.
- [ ] Optimize Docker image
  - it’s currently way to big but it works.
  - [ ] use static binary and use a smaller image that supports `ffmpeg`
- [ ] Delete files after processing
  - Currently using the system call to send the file so delete has to wait till
    after send is complete
  - This could be done with a background Q or something
- [ ] Process images in batches instead of spawning an `ffmpeg` process per 
  image
- [ ] import `ffmpeg` directly as a `c` target instead of spawning a process.
  - [ ] Compile as WASM target