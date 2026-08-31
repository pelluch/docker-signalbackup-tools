# Upstream tags YYYYMMDD, and YYYYMMDD-N for a same-day re-cut.
# renovate: datasource=github-tags depName=bepaald/signalbackup-tools
ARG SBT_REF=20260822

# digest pinned so Renovate raises a PR whenever trixie-slim is republished
FROM debian:trixie-slim@sha256:d7e12182ce18b85b93007c1dedf31f2d29e01ccf3182cc4017c709b6259bc132 AS build
ARG SBT_REF

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential cmake git ca-certificates libssl-dev libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

# cap compile parallelism by available RAM
RUN set -eu; \
    git clone https://github.com/bepaald/signalbackup-tools /src; \
    cd /src; \
    git checkout "${SBT_REF}"; \
    cmake -B build -DCMAKE_BUILD_TYPE=Release -DWITHOUT_DBUS=1; \
    mem_gb=$(awk '/MemTotal/{printf "%d", $2/1024/1024}' /proc/meminfo); \
    cap=$(( mem_gb / 2 )); if [ "$cap" -lt 1 ]; then cap=1; fi; \
    jobs=$(nproc); if [ "$jobs" -gt "$cap" ]; then jobs="$cap"; fi; \
    echo "compiling signalbackup-tools with -j$jobs (nproc=$(nproc), MemTotal=${mem_gb}GB, cap=$cap)"; \
    cmake --build build -j "$jobs"

# same suite as the build stage; the binary links its glibc and libstdc++
FROM debian:trixie-slim@sha256:d7e12182ce18b85b93007c1dedf31f2d29e01ccf3182cc4017c709b6259bc132
ARG SBT_REF
LABEL org.opencontainers.image.title="signalbackup-tools"
LABEL org.opencontainers.image.source="https://github.com/bepaald/signalbackup-tools"
LABEL org.opencontainers.image.version="${SBT_REF}"

RUN apt-get update && apt-get install -y --no-install-recommends \
      libssl3 libsqlite3-0 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/build/signalbackup-tools /usr/local/bin/signalbackup-tools
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
