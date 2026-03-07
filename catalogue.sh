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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabiling default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabiling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop user"
else 
    echo -e "system user roboshop already created.... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "creating /app"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading code"

rm -rf /app/*
cd /app
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzipping of code"

npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue 
VALIDATE $? "Restarting catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb client"

mongosh --host mongodb.anilkumar.shop < /app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Loading data to mongodb"