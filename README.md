# coronaCv deploy

## first time install
```
curl -fsSL https://raw.githubusercontent.com/yehiyam/coronaCv-deploy/master/scripts/deploy.sh | bash
cd coronaCv-deploy
docker-compose pull
# set env variables in .env file if needed
./scripts/setProperty.sh COVIEW_PORT 8888 .env
./scripts/setProperty.sh COVIEW_HOST 127.0.0.1 .env
./scripts/setProperty.sh COVIEW_ENABLE true .env

echo 
# start
docker-compose up
```


### obtain certificate or create a self signed one
```
cd nginx/certs
openssl req -nodes -new -x509 -keyout server.key -out server.cert \
    -subj "/C=IL/ST=NRW/L=Haifa/O=Monitor/OU=DevOps/CN=monitor/emailAddress=dev@www.example.com"
```
