# ZeroVPN: zero-configuration OpenVPN using SSH
Here's why this exists. I used to host an OpenVPN server on EC2 so I could get
to each of my machines from anywhere on the internet. But each client required
another setup step with the `easy-rsa` stuff, and I'd usually have to write a
connection script/conffile for each one. It's a drag.

ZeroVPN is a dockerized server that uses SSH to automatically configure
clients. Clients just need to have `ssh`, `openvpn`, and the `zerovpn` script
installed; then they use the SSH connection to download a transient OpenVPN
configuration and connect. The configuration is deleted when the client
disconnects.

## Usage
First create an SSH key. Anyone with this key can connect to the VPN:

```sh
$ ssh-keygen -f ~/.ssh/vpn-key
```

Then build and launch the server:

```sh
$ cp ~/.ssh/vpn-key.pub id_rsa.pub
$ sudo docker build -t zerovpn .
$ sudo docker run --privileged -d -p 1194:1194/udp -p 2222:22 zerovpn
```

**NOTE:** The `--privileged` option is required; otherwise OpenVPN will
silently fail to establish the connection. I'm not entirely sure why this is,
but it's something to do with the tun/tap drivers.

Note that running the container takes a minute or so because OpenVPN generates
a server key. This happens each time you launch the image. The container will
refuse SSH connections until it's fully booted.

Now anyone with `.ssh/vpn-key` can use `zerovpn` to connect to the OpenVPN:

```sh
# usage: zerovpn client_ip ssh options...
$ zerovpn 10.8.0.4 -p 2222 -i ~/.ssh/vpn-key vpn@your-docker-server.com
```
