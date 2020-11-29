FROM debian:buster as builder
WORKDIR /build/

RUN apt update && apt install -y git-core git
RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git . && git submodule init && git submodule update
RUN apt install -y cmake gcc g++ libncurses5-dev libreadline-dev libssl-dev make zlib1g-dev
RUN CMAKE_FLAGS="-DSE_PIDDIR=/opt/softether/pid -DSE_LOGDIR=/opt/softether/log -DSE_DBDIR=/opt/softether/config" ./configure
RUN make -j8 -C build
RUN mkdir /output/
RUN cp build/libcedar.so build/libmayaqua.so build/hamcore.se2 build/vpnclient build/vpncmd /output/

FROM debian:buster-slim
WORKDIR /opt/softether/

RUN apt update && apt install -y libncurses6 libreadline7 libtinfo5 libssl1.1 isc-dhcp-client iproute2 iptables\
	&& rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

COPY --from=builder /output/* /opt/softether/
COPY ./vpnmanager ./config/ /opt/softether/
COPY ./vpn-dhcp-hook /etc/dhcp/dhclient-exit-hooks.d/
RUN mkdir pid log config

ENV LD_LIBRARY_PATH .
ENTRYPOINT ["/opt/softether/vpnmanager"]
