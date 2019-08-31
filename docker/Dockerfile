FROM postgres:10

RUN apt-get update && apt-get install -y \
    autoconf \
    build-essential \
    libtool \
    postgresql-server-dev-${PG_MAJOR} \
    sudo

ADD https://github.com/Numbertext/libnumbertext/releases/download/1.0.5/libnumbertext-1.0.5.tar.xz /data/
COPY Makefile /data/

WORKDIR /data
RUN make dependencies

COPY ./ /data/
RUN chown -R postgres:postgres /data/
# Patch the entrypoint script so it always initializes the DB.
RUN patch /usr/local/bin/docker-entrypoint.sh < /data/docker/docker-entrypoint.patch

# Build pg_libnumbertext.
RUN make && make install

CMD ["/data/docker/run-tests.sh", "${PG_MAJOR}"]
