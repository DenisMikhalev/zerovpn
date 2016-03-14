FROM ubuntu:15.10

RUN apt-get update && apt-get install -y openvpn openssh-server git sudo

RUN cd /etc/openvpn \
    && git clone -b release/2.x \
           git://github.com/OpenVPN/easy-rsa easy-rsa-source

RUN useradd -ms /bin/bash vpn -G adm,sudo \
    && echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config \
    && echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir /var/run/sshd \
    && mkdir /etc/openvpn/clients \
    && mkdir /home/vpn/.ssh \
    && chown vpn /home/vpn/.ssh

ADD id_rsa.pub /home/vpn/.ssh/authorized_keys
ADD new-client openvpn-server.conf openvpn-client.conf /home/vpn/
ADD docker-entrypoint /

RUN mv /home/vpn/openvpn-server.conf /etc/openvpn/server.conf \
    && chown vpn:vpn /home/vpn/.ssh/authorized_keys \
    && chmod 0700 /home/vpn/.ssh/authorized_keys

EXPOSE 22
EXPOSE 1194

CMD ["/docker-entrypoint"]
