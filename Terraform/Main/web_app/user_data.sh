#! /bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
export ECR=494992235231.dkr.ecr.us-east-1.amazonaws.com
export DBECR=$ECR/database-image-docker-assignment:v0.1
export APPECR=$ECR/app-image-docker-assignment:v0.1
export DBPORT=3306
export DBUSER=root
export DATABASE=employees
export DBPWD=pw
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR}
sudo docker pull $DBECR
sudo docker pull $APPECR
sudo docker network create sudeepBridge
sudo docker run --name mysql-db --network=sudeepBridge -d -e MYSQL_ROOT_PASSWORD=pw $DBECR
export DBHOST=$(sudo docker inspect --format '{{ .NetworkSettings.Networks.sudeepBridge.IPAddress }}' mysql-db)
sleep 40
export APP_COLOR=blue
sudo docker run -d --name blue -p 8081:8080  --network=sudeepBridge -e APP_COLOR=$APP_COLOR -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD $APPECR
export APP_COLOR=green
sudo docker run -d --name lime -p 8082:8080  --network=sudeepBridge -e APP_COLOR=$APP_COLOR -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD $APPECR
export APP_COLOR=pink
sudo docker run -d --name pink -p 8083:8080  --network=sudeepBridge -e APP_COLOR=$APP_COLOR -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD $APPECR
