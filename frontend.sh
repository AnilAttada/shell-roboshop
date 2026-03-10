#!/bin/bash

source ./common.sh
check_root

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabiling default nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabiling nginx"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping code"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Removing content nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Copying nginx conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting nginx"

print_time