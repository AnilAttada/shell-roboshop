#!/bin/bash

source ./common.sh
app_name=mongodb

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabled Mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Started Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing Mongod conf file"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting Mongodb"

print_time