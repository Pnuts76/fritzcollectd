ARG ALPINE_VERSION=latest

FROM alpine:$ALPINE_VERSION

LABEL maintainer="wolfgang.keller@wobilix.de"

WORKDIR /

RUN apk add --no-cache --virtual .build-deps curl-dev git gcc autoconf automake flex bison libcurl libtool pkgconf make libxslt-dev musl-dev linux-headers python3-dev py3-pip yajl-dev && \
    apk add --no-cache libxslt bash tzdata musl && \
    pip install --no-cache-dir fritzcollectd && \
    git clone https://github.com/collectd/collectd.git collectd && \
    cd collectd && \
    ./build.sh && \
    ./configure --prefix="/usr" --sysconfdir="/etc/collectd" --disable-werror && \
    make  && \
    make install && \
    cd .. && \
    rm -rf collectd && \
    apk del --no-cache .build-deps && \
    apk add --no-cache py3-requests py3-setuptools && \
    rm -rf /var/cache/apk/*

VOLUME ["/etc/collectd"]
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/collectd", "-f"]

