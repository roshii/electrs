# electrs-docker

Docker image for [electrs](https://github.com/romanz/electrs), an Electrum server in Rust.

## Build

```sh
docker build --pull -t electrs .
```

Pin a release with `--build-arg VERSION=v0.12.0

- Runs as UID 1000 by default. Override with `--user <uid>:<gid>`.
- State lives in `/data`.