# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest as unrar

FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBITTORRENT_VERSION
ARG QBT_CLI_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# install runtime packages and qbitorrent-cli
RUN \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache \
    icu-libs \
    p7zip \
    python3 \
    qt6-qtbase-sqlite && \
  echo "**** install qbittorrent ****" && \
  if [ -z ${QBITTORRENT_VERSION+x} ]; then \
    QBITTORRENT_VERSION=$(curl -sL "https://api.github.com/repos/userdocs/qbittorrent-nox-static/releases" | \
    jq -r 'first(.[] | select(.prerelease == true) | .tag_name)'); \
  fi && \
  curl -o \
    /app/qbittorrent-nox -L \
    "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${QBITTORRENT_VERSION}/x86_64-qbittorrent-nox" && \
  chmod +x /app/qbittorrent-nox && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /root/.cache \
    /tmp/*

# add local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8080 6881 6881/udp

VOLUME /config
