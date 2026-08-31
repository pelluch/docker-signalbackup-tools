# signalbackup-tools

A repository holding a Dockerfile that builds [signalbackup-tools](https://github.com/bepaald/signalbackup-tools) from its latest release tag.

## Usage

```sh
docker run --rm -v /some/work:/work "$IMAGE" \
  /work/signal.backup --output /work/dump --onlydb
```

`SIGNAL_PASSPHRASE_FILE` is a required env var.

## Bumping

Renovate raises `SBT_REF`.
