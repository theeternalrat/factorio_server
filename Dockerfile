FROM frolvlad/alpine-glibc:alpine-3.9

LABEL maintainer="https://github.com/factoriotools/factorio-docker"

ARG USER=container
ARG GROUP=container
ARG PUID=845
ARG PGID=845

ENV PORT=34197 \
    RCON_PORT=27015 \
    VERSION=0.17.47 \
    SHA1=504edefb1651aaec6a943dd74b0c7aba1b9551a0 \
    SAVES=/home/container/factorio/saves \
    CONFIG=/home/container/factorio/config \
    MODS=/home/container/factorio/mods \
    SCENARIOS=/home/container/factorio/scenarios \
    SCRIPTOUTPUT=/home/container/factorio/script-output \
    PUID="$PUID" \
    PGID="$PGID"

RUN mkdir -p /opt /home/container/factorio && \
    apk add --update --no-cache pwgen su-exec binutils gettext libintl shadow && \
    apk add --update --no-cache --virtual .build-deps curl && \
    curl -sSL "https://www.factorio.com/get-download/$VERSION/headless/linux64" \
        -o /tmp/factorio_headless_x64_$VERSION.tar.xz && \
    echo "$SHA1  /tmp/factorio_headless_x64_$VERSION.tar.xz" | sha1sum -c && \
    tar xf "/tmp/factorio_headless_x64_$VERSION.tar.xz" --directory /opt && \
    chmod ugo=rwx /opt/factorio && \
    rm "/tmp/factorio_headless_x64_$VERSION.tar.xz" && \
    ln -s "$SAVES" /opt/factorio/saves && \
    ln -s "$MODS" /opt/factorio/mods && \
    ln -s "$SCENARIOS" /opt/factorio/scenarios && \
    ln -s "$SCRIPTOUTPUT" /opt/factorio/script-output && \
    apk del .build-deps && \
    addgroup -g "$PGID" -S "$GROUP" && \
    adduser -u "$PUID" -G "$GROUP" -s /bin/sh -h /home/container -SDH "$USER" && \
    chown -R "$USER":"$GROUP" /opt/factorio /home/container/factorio

USER container

VOLUME /home/container/factorio

EXPOSE $PORT/udp $RCON_PORT/tcp

WORKDIR /home/container/factorio

COPY files/ .

CMD ["/bin/sh", "docker-entrypoint.sh"]