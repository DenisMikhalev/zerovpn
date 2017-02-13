FROM ubuntu:16.04

ARG ip_base

RUN apt-get update && apt-get install -y openvpn openssh-server git

RUN cd /etc/openvpn \
    && git clone -b release/2.x \
           git://github.com/OpenVPN/easy-rsa easy-rsa-source

RUN useradd -ms /bin/bash vpn \
    && echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config \
    && mkdir /var/run/sshd \
    && mkdir /etc/openvpn/clients \
    && mkdir /home/vpn/.ssh \
    && chown vpn /home/vpn/.ssh \
    && chmod a+rX /etc/openvpn/easy-rsa/keys

ADD authorized_keys new-client openvpn-server.conf openvpn-client.conf \
      docker-entrypoint \
    /home/vpn/

RUN sed -ri 's/IP_BASE_PREFIX/'$ip_base'/g' /home/vpn/* \
 && mv /home/vpn/openvpn-server.conf /etc/openvpn/server.conf \
 && mv /home/vpn/authorized_keys /home/vpn/.ssh/ \
 && mv /home/vpn/docker-entrypoint / \
 && chown vpn:vpn /home/vpn/.ssh/authorized_keys \
 && chmod 0700 /home/vpn/.ssh/authorized_keys

EXPOSE 22
EXPOSE 1195

CMD /docker-entrypoint
