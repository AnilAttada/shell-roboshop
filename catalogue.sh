#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb client"

STATUS=$(mongosh --host mongodb.anilkumar.shop --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.anilkumar.shop < /app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data to mongodb"
else
    echo -e "Data is exist .... $Y SKIPPING $N"
fi

print_time


    
