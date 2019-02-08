FROM abiosoft/caddy:builder as builder

ARG version="0.11.3"
ARG plugins="filebrowser,cors,realip,expires,cache,extauth"

RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh

FROM alpine:3.8
LABEL maintainer "NoEnv"

ARG version="0.11.3"
LABEL caddy_version="$version"

ENV ACME_AGREE="false"

ENV ENABLE_TELEMETRY="false"

RUN apk add --no-cache openssh-client git

COPY --from=builder /install/caddy /usr/bin/caddy

RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

EXPOSE 80 443 2015
VOLUME /root/.caddy /srv
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html

COPY --from=builder /go/bin/parent /bin/parent

ENTRYPOINT ["/bin/parent", "caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]

