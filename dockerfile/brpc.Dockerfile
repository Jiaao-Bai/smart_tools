FROM ubuntu:22.04

ENV http_proxy  http://127.0.0.1:7890
ENV https_proxy http://127.0.0.1:7890

# prepare env
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        apt-utils \
        openssl \
        ca-certificates

# install deps
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        g++ \
        make \
        libssl-dev \
        libgflags-dev \
        libprotobuf-dev \
        libprotoc-dev \
        protobuf-compiler \
        libleveldb-dev \
        libsnappy-dev && \
        apt-get clean -y

#RUN git clone https://github.com/apache/incubator-brpc.git
#RUN cd incubator-brpc && sh config_brpc.sh --headers=/usr/include --libs=/usr/lib && \
#    make -j "$(nproc)"
