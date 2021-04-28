FROM ubuntu:20.04
RUN apt update && apt-get install --no-install-recommends --no-install-suggests -y \
    apt-utils inetutils-tools iproute2 vim procps inetutils-ping net-tools telnet curl \
    iptables conntrack ipvsadm ipset kmod ca-certificates less netcat \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD K8S_BINARY /K8S_BINARY
ENTRYPOINT [ "/K8S_BINARY" ]