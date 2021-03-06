#
# Docker file for ChRIS production server
#
# Build with
#
#   docker build -t <name> .
#
# For example if building a local version, you could do:
#
#   docker build -t local/chris .
#
# In the case of a proxy (located at say 10.41.13.4:3128), do:
#
#    export PROXY="http://10.41.13.4:3128"
#    docker build --build-arg http_proxy=${PROXY} --build-arg UID=$UID -t local/chris .
#
# To run an interactive shell inside this container, do:
#
#   docker run -ti --entrypoint /bin/bash local/chris
#
# To pass an env var HOST_IP to container, do:
#
#   docker run -ti -e HOST_IP=$(ip route | grep -v docker | awk '{if(NF==11) print $9}') --entrypoint /bin/bash local/chris
#

FROM fnndsc/ubuntu-python3:latest
MAINTAINER fnndsc "dev@babymri.org"

# Pass a UID on build command line (see above) to set internal UID
ARG UID=1001
ENV UID=$UID VERSION="0.1"

ENV APPROOT="/home/localuser/chris_backend" REQPATH="/usr/src/requirements"
COPY ["./requirements", "${REQPATH}"]
COPY ["./docker-entrypoint.sh", "/usr/src"]

RUN apt-get update \
  && apt-get install -y libmysqlclient-dev                            \
  && apt-get install -y libssl-dev libcurl4-openssl-dev               \
  && apt-get install -y apache2 apache2-dev                           \
  && apt-get install -y bsdmainutils vim net-tools inetutils-ping    \
  && pip install --upgrade pip                                        \
  && pip install -r ${REQPATH}/local.txt                           \
  && useradd -u $UID -ms /bin/bash localuser

# Start as user localuser
USER localuser

COPY --chown=localuser ["./chris_backend", "${APPROOT}"]

WORKDIR $APPROOT
ENTRYPOINT ["/usr/src/docker-entrypoint.sh"]
EXPOSE 8000
