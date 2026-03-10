#!/bin/bash

source ./common.sh
app_name=shipping

check_root

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

app_setup
maven_setup
systemd_setup

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

print_time