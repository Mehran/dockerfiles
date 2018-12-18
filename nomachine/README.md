*) create Container
```
docker run -d -p 4000:4000 -p 4080:4080 -p 4080:4080/udp -p 4443:4443 -p 4443:4443/udp --cap-add=SYS_PTRACE  mehran/streaming
```
*) Done :)
