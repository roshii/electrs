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

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN --mount=type=cache,target=/build/target \
    --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo build --release --locked \
 && cp target/release/electrs /usr/local/bin/electrs


FROM debian:trixie-slim
ARG VERSION

LABEL org.opencontainers.image.source="https://github.com/romanz/electrs" \
      org.opencontainers.image.title="electrs" \
      org.opencontainers.image.version="${VERSION}"

COPY --from=builder /usr/local/bin/electrs /usr/local/bin/electrs

RUN mkdir /data && chmod 1777 /data
ENV HOME=/data
WORKDIR /data
VOLUME /data

USER 1000:1000

STOPSIGNAL SIGINT
ENTRYPOINT ["electrs"]