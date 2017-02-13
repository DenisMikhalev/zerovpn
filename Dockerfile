FROM zerovpn-base:latest

ARG ip_base_prefix

ADD authorized_keys new-client openvpn-server.conf openvpn-client.conf \
      docker-entrypoint login-shell \
    /home/vpn/

RUN sed -ri 's/IP_BASE_PREFIX/'$ip_base_prefix'/g' /home/vpn/* \
 && mv /home/vpn/openvpn-server.conf /etc/openvpn/server.conf \
 && mv /home/vpn/authorized_keys /home/vpn/.ssh/ \
 && mv /home/vpn/docker-entrypoint / \
 && chown vpn:vpn /home/vpn/.ssh/authorized_keys \
 && chsh -s /home/vpn/login-shell vpn \
 && chmod 0700 /home/vpn/.ssh/authorized_keys

EXPOSE 22
EXPOSE 1194

CMD /docker-entrypoint
