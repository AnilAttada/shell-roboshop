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

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 ...$G SUCCESS $N" | tee -a $LOG_FILE
    else    
    echo -e "$2 ..... $R FAILURE $N" | tee -a $LOG_FILE
    fi

}

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven and Java"

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

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading code"

rm -rf /app/*
cd /app
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping of code"

mvn clean package &>>$LOG_FILE
VALIDATE $? " Packaging the shipping application"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Moving and renaming jar file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Copying user"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable shipping &>>$LOG_FILE
systemctl start shipping 
VALIDATE $? "Restarting shiping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.anilkumar.shop -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities'
if  [ $? -ne 0 ]
then
    mysql -h mysql.anilkumar.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.anilkumar.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.anilkumar.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into mysql"
else
    echo -e "Data is already loaded into mysql.... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? " Restarting shipping"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE