#!/bin/bash

echo "Which port do you want to set?"
read -p "(default 8050) > " webport
if [ -z $webport ]; then
    webport=8050
    echo "[+] set port: $webport"
elif echo $webport|grep -q '^[1-9][0-9]*$'; then
    echo "[+] set port $webport"
else
    echo "[-] Please input number 1-65535"
fi
sed -i 's/^OPEN_PORT.\+/OPEN_PORT='${webport}'/g' $PWD/.env

read -p "Set leanote admin username(default admin): " adminusername
if [ -z $adminusername ]; then
    adminusername="admin"
fi
echo "[+] set admin name: $adminusername"

read -p "Set your servername(used for setting url such as, note.xxxx.com,default localhost): " servername
if [ -z $servername ]; then
    servername="localhost"
fi

echo 'Press any key to continue...'
read anykey

mongo_password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
echo "[+] setting MONGO_PASSOWRD: $mongo_password"
sed -i 's/^site\.url.\+/site.url=http:\/\/'${servername}':'${webport}'/g' $PWD/leanote_src/conf/app.conf
sed -i 's/^MONGO_PASSWORD.\+/MONGO_PASSWORD='${mongo_password}'/g' $PWD/.env

echo "[+] reading envs from .env"
export $(xargs < .env)
cat .env
echo "[+] setting webapp config: $PWD/leanote_src/conf/app.conf"
sed -i 's/^http\.port.\+/http.port='${INTRA_PORT}'/g' $PWD/leanote_src/conf/app.conf
sed -i 's/^db\.host.\+/db.host='${MONGO_HOST}'/g' $PWD/leanote_src/conf/app.conf
sed -i 's/^db\.port.\+/db.port='${MONGO_PORT}'/g' $PWD/leanote_src/conf/app.conf
sed -i "s/^app\.secret.\+/app.secret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 64)/g" $PWD/leanote_src/conf/app.conf

echo "[+] starting leaote webserver with docker..."
if ! command -v docker-compose >/dev/null 2>&1; then
     echo "[-] please check your docker and docker-compose..."
fi
docker-compose up -d

docker exec -it leanote_db mongorestore -h 127.0.0.1 -d leanote /leanote_db

docker-compose ps

echo "**************************************"
echo " url: http://$servername:$webport"
echo " admin username: $adminusername"
echo " admin password: abc123"
echo "**************************************"
