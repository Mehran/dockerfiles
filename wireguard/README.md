1) create Container

```
docker run --rm -it \
	--name wireguard \
        --cap-add net_admin \
	--cap-add sys_module \
 	-v /lib/modules:/lib/modules \
 	-v /usr/src:/usr/src \
	-p 51820:51820/udp \
	-p 53:53/udp \
  	mehran/wireguard
 ```
2) in Container :
```
chmod +x ./wg.sh
./wg.sh
```

# Note :
if you use Microsoft Azure first should disable DNS

```
sudo systemctl disable systemd-resolved.service
sudo systemctl stop systemd-resolved
```
