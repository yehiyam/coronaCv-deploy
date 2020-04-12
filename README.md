# coronaCv deploy
## obtain certificate or create a self signed one
```
cd nginx/certs
openssl req -nodes -new -x509 -keyout server.key -out server.cert \
    -subj "/C=IL/ST=NRW/L=Haifa/O=Monitor/OU=DevOps/CN=monitor/emailAddress=dev@www.example.com"
```
## deploys the server with docker-compose
```console
git pull
export BASE=/data/
docker-compose up 
```
