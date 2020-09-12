FROM arm32v7/debian:stretch-slim as builder
WORKDIR /build/

RUN apt update && apt install -y git-core git
RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git . && git submodule init && git submodule update
RUN apt install -y cmake gcc g++ libncurses5-dev libreadline-dev libssl-dev make zlib1g-dev
RUN ./configure
RUN make -j8 -C build
RUN mkdir /output/
RUN cp build/libcedar.so build/libmayaqua.so build/hamcore.se2 build/vpnclient build/vpncmd /output/

FROM arm32v7/debian:stretch-slim
WORKDIR /opt/softether/


RUN apt update && apt install -y libncurses5 libreadline7 libtinfo5 libssl1.1 isc-dhcp-client iproute2\
	&& rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

COPY --from=builder /output/* /opt/softether/
COPY ./vpnmanager /opt/softether/

ENV LD_LIBRARY_PATH .
#ENTRYPOINT ["/bin/sh", "-c", "/opt/softether/vpnclient start; /opt/softether/vpnmanager"]
ENTRYPOINT ["/opt/softether/vpnmanager"]
