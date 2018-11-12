#!/bin/bash
### Author ### 
# By : Mehran Goudarzi
# Release : 2018-10-24
# Description : WireGuard Automation - Server Side
# Version : 1.1
###############
set +H
echo -e '\n' | add-apt-repository ppa:wireguard/wireguard
apt-get update
apt-get install wireguard-dkms wireguard-tools linux-headers-$(uname -r) -y

printf "\e[1;92m[*] Generate server and client keys!\e[0m\n"
umask 077
wg genkey | tee server_private_key | wg pubkey > server_public_key
wg genkey | tee client_private_key | wg pubkey > client_public_key
server_private_key=$(cat server_private_key)
server_public_key=$(cat server_public_key)
client_private_key=$(cat client_private_key)
client_public_key=$(cat client_public_key)
server_ip=$(curl ipinfo.io/ip)
port=51820


printf "\e[1;92m[*] Generate server config!\e[0m\n"
echo "[Interface]
Address = 10.200.200.1/24
SaveConfig = true
PrivateKey = $server_private_key
ListenPort = $port

[Peer]
PublicKey = $client_public_key
AllowedIPs = 10.200.200.2/32" > /etc/wireguard/wg0.conf
sleep 2

printf "\e[1;92m[*] Generate Client config!\e[0m\n"
echo "[Interface]
Address = 10.200.200.2/32
PrivateKey = $client_private_key
DNS = 10.200.200.1

[Peer]
PublicKey = $server_public_key
Endpoint = $server_ip:$port
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21" > wg0-client.conf
sleep 2

printf "\e[1;92m[*] Enable the WireGuard interface on the server!\e[0m\n"
chown -v root:root /etc/wireguard/wg0.conf
chmod -v 600 /etc/wireguard/wg0.conf
wg-quick up wg0
systemctl enable wg-quick@wg0.service #Enable the interface at boot
sleep 2

printf "\e[1;92m[*] Check WireGuard interface is up or not ...\e[0m\n"
sleep 1
if grep -q 'wg0' <<< "$(ifconfig)" ; then
sleep 2
printf "\e[1;92m[*] wg0 is UP!\e[0m\n"
else
printf "\e[1;91mFailed!\e[0m\n"
exit
fi

printf "\e[1;92m[*] Enable IP forwarding on the server ...\e[0m\n"
sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p
echo 1 > /proc/sys/net/ipv4/ip_forward
sleep 1

printf "\e[1;92m[*] Configure firewall rules on the server!\e[0m\n"

printf "\e[1;92m[*] Stopping firewall and allowing everyone..."\e[0m\n"
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
printf "\e[1;92m[*] Adding firewall rules ..."\e[0m\n"
sleep 2
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m udp --dport $port -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s 10.200.200.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s 10.200.200.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o eth0 -j MASQUERADE
export DEBIAN_FRONTEND=noninteractive
apt-get -yq install iptables-persistent
systemctl enable netfilter-persistent
netfilter-persistent save
sleep 2

printf "\e[1;92m[*] Configure DNS!\e[0m\n"
apt-get install unbound unbound-host -y
curl -s -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache
cp /usr/share/dns/root.key /var/lib/unbound/
systemctl disable systemd-resolved.service
service systemd-resolved stop
echo "" > /etc/unbound/unbound.conf
echo "server:

  num-threads: 4

  #Enable logs
  verbosity: 1

  #list of Root DNS Server
  root-hints: "/var/lib/unbound/root.hints"

  #Use the root servers key for DNSSEC
  auto-trust-anchor-file: "/var/lib/unbound/root.key"

  #Respond to DNS requests on all interfaces
  interface: 0.0.0.0
  max-udp-size: 3072

  #Authorized IPs to access the DNS Server
  access-control: 0.0.0.0/0                 refuse
  access-control: 127.0.0.1                 allow
  access-control: 10.200.200.0/24         allow

  #not allowed to be returned for public internet  names
  private-address: 10.200.200.0/24

  # Hide DNS Server info
  hide-identity: yes
  hide-version: yes

  #Limit DNS Fraud and use DNSSEC
  harden-glue: yes
  harden-dnssec-stripped: yes
  harden-referral-path: yes

  #Add an unwanted reply threshold to clean the cache and avoid when possible a DNS Poisoning
  unwanted-reply-threshold: 10000000

  #Have the validator print validation failures to the log.
  val-log-level: 1

  #Minimum lifetime of cache entries in seconds
  cache-min-ttl: 1800 

  #Maximum lifetime of cached entries
  cache-max-ttl: 14400
  prefetch: yes
  prefetch-key: yes" > /etc/unbound/unbound.conf
chown -R unbound:unbound /var/lib/unbound
systemctl enable unbound
service unbound restart
sleep 2

printf "\e[1;92m[*] Your WireGurad Server is Ready for Use!\e[0m\n"
