FROM ubuntu:18.04

ENV USER root
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Etc/UTC

WORKDIR /root/firmware-analysis-plus

RUN echo 'root:root' | chpasswd

RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list && \
    grep -v '^deb http://security' /etc/apt/sources.list > /tmp/list && cat /tmp/list > /etc/apt/sources.list && rm /tmp/list && \
    apt-get clean && \
    apt-get update --allow-unauthenticated && apt-get install -y lsb-release sudo python3-pip python3-pexpect unzip busybox-static fakeroot kpartx snmp uml-utilities util-linux vlan qemu-utils binwalk && \
    apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/apt/lists/*

RUN pip3 install python-magic --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple/

COPY . .

RUN sed -i "/FIRMWARE_DIR=/c\FIRMWARE_DIR=$(realpath ./firmadyne)" firmadyne/firmadyne.config && \
    sed -i 's/psql/#psql/' ./firmadyne/scripts/getArch.sh && \
    sed -i 's/env python/env python3/' ./firmadyne/sources/extractor/extractor.py && \
    sed -i "/firmadyne_path=/c\firmadyne_path=$(realpath ./firmadyne)" fap.config && \
    sed -i "/sudo_password=/c\sudo_password=root" fap.config

RUN ln -s $(pwd)/qemu-builds/2.5.0/qemu-system-mips /usr/bin/qemu-system-mips && \
    ln -s $(pwd)/qemu-builds/2.5.0/qemu-system-mipsel /usr/bin/qemu-system-mipsel && \
    ln -s $(pwd)/qemu-builds/2.5.0/qemu-system-arm /usr/bin/qemu-system-arm && \
    ln -s $(pwd)/qemu-builds/2.5.0/share/qemu /usr/share/qemu

CMD [ "/bin/bash" ]
