# syntax=docker/dockerfile:1

ARG VERSION=v0.12.0

FROM rust:1-slim-trixie AS builder
ARG VERSION
WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    libclang-dev \
    libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/romanz/electrs.git#${VERSION} .

# Avoids huge RAM usage when building under QEMU (ARM)
# https://users.rust-lang.org/t/cargo-uses-too-much-memory-being-run-in-qemu/76531/2
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo install --locked --path .


FROM debian:trixie-slim
ARG VERSION

LABEL org.opencontainers.image.source="https://github.com/romanz/electrs" \
      org.opencontainers.image.title="electrs" \
      org.opencontainers.image.version="${VERSION}"

COPY --from=builder /usr/local/cargo/bin/electrs /usr/local/bin/electrs

RUN mkdir /data && chmod 1777 /data
ENV HOME=/data
WORKDIR /data
VOLUME /data

USER 1000:1000
EXPOSE 50001

STOPSIGNAL SIGINT
ENTRYPOINT ["electrs"]