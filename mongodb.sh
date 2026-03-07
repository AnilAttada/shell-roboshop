#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

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