FROM ubuntu:16.04

LABEL maintainer "ferrari.marco@gmail.com"

# Install the necessary packages
RUN apt-get update \
  && apt-get install -y \
    dnsmasq \
    pxelinux \
    syslinux-common \
    wget

# Stop the dnsmasq service that is automatically started after installing the
# corresponding package
RUN service dnsmasq stop

# Create the TFTP root directory
RUN mkdir -p /var/lib/tftpboot

# Download and extract MemTest86+
ENV MEMTEST_VERSION 5.01
RUN wget http://www.memtest.org/download/$MEMTEST_VERSION/memtest86+-$MEMTEST_VERSION.bin.gz \
  && gzip -d memtest86+-$MEMTEST_VERSION.bin.gz \
  && mkdir -p /var/lib/tftpboot/memtest \
  && mv memtest86+-$MEMTEST_VERSION.bin /var/lib/tftpboot/memtest/memtest86+

# Setup PXE and TFTP
RUN ln -sf /usr/lib/PXELINUX/lpxelinux.0 /var/lib/tftpboot/ \
  && ln -sf /usr/lib/syslinux/modules/bios/libutil.c32 /var/lib/tftpboot/ \
  && ln -sf /usr/lib/syslinux/modules/bios/ldlinux.c32 /var/lib/tftpboot/ \
  && ln -sf /usr/lib/syslinux/modules/bios/menu.c32 /var/lib/tftpboot/
COPY tftpboot/ /var/lib/tftpboot

# Setup DNSMASQ
COPY etc/ /etc

# Start dnsmasq. It picks up default configuration from /etc/dnsmasq.conf and
# /etc/default/dnsmasq plus any command line switch
ENTRYPOINT ["dnsmasq", "--no-daemon"]
CMD ["--dhcp-range=192.168.56.2,proxy"]
