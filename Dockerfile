FROM alpine:3.13 as bins
COPY target/output/minirust /app/minirust
RUN apk add binutils && strip /app/minirust

FROM opensuse/leap:15.2 as opensuse
RUN ldd /bin/echo | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

FROM scratch
LABEL maintainer="giggio@giggio.net"
ENTRYPOINT [ "/minirust" ]
COPY --from=bins /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=opensuse /bin/echo .
COPY --from=opensuse  /deps /
COPY --from=bins /app/minirust .
