1) create Container

```
docker run -it \
--name openvpn \
--restart always \
--cap-add=NET_ADMIN \
--device=/dev/net/tun \
-p 1194:1194/udp \
mehran/openvpn
 ```
2) in Container :
```
bash openvpn-install.sh
```
3) Done :)
