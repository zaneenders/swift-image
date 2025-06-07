FROM swift:6.1-jammy AS build

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y\
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve

COPY . .

# TODO use static sdk 
RUN swift build -c release --static-swift-stdlib

WORKDIR /staging

RUN cp -r /build/Fixtures ./Fixtures

RUN cp "$(swift build --package-path /build -c release --show-bin-path)/swift-image" ./ 


FROM swift:6.1-jammy

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
    ffmpeg \
    && rm -r /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app webserver

WORKDIR /app

COPY --from=build --chown=webserver:webserver /staging /app

USER webserver:webserver

EXPOSE 8080

ENTRYPOINT ["./swift-image"]
CMD []
