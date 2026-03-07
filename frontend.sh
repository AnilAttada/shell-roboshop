#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)"  | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then 
    echo -e "$R ERROR :: run with root access $N" | tee -a $LOG_FILE
    exit 1
else 
    echo -e "$G running with root access $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 ...$G SUCCESS $N" | tee -a $LOG_FILE
    else    
    echo -e "$2 ..... $R FAILURE $N" | tee -a $LOG_FILE
    fi

}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabiling default nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabiling nginx"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Unzipping code"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Removing content nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx conf"

systemctl restart nginx 
VALIDATE $? "Restarting nginx"
