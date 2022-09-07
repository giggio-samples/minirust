FROM alpine:3.16 as bins
RUN ldd /bin/echo | tr -s '[:blank:]' '\n' | grep '^/' \
    | sort | uniq \
    | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

FROM scratch
LABEL maintainer="giggio@giggio.net"
ENTRYPOINT [ "/minirust" ]
COPY --from=bins /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=bins /bin/echo /deps /
COPY target/output/minirust .