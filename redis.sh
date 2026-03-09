#!/bin/bash

START_TIME=$(date +%s)
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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabiling redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabiling redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etC/redis/redis.conf
VALIDATE $? "Edited redis.conf flles"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabiling redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting redis"

END_TIME=$(date +%s)
TIME_TAKEN=$(( $END_TIME - $START_TIME ))

echo -e "Script execution completed successfully, $Y time takes: $TIME_TAKEN $N" | tee -a $LOG_FILE