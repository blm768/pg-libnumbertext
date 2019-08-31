#!/bin/sh

docker build -t pg_libnumbertext_test -f docker/Dockerfile .
docker run -it --rm --mount type=tmpfs,destination=/var/lib/postgresql/data pg_libnumbertext_test
