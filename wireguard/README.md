Lunch Container :

docker run --rm -it \
	--name wireguard \
  --cap-add net_admin \
	--cap-add sys_module \
 	-v /lib/modules:/lib/modules \
 	-v /usr/src:/usr/src \
	-p 51820:51820/udp \
	-p 53:53/udp \
  wireguard
