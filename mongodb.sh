#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then
    echo "Please run the script with Root user" | tee -a $LOGS_FILE
    exit 1
elseif 
    echo "Running the script with Root user" | tee -a $LOGS_FILE
fi    

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... :: $R FAILED $N" | tee -a $LOGS_FILE
    elseif 
        echo -e "$2 ... :: $R SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

cp -p ./mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing mongodb server"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGS_FILE
VALIDATE $? "Allowing remote connections"

systemctl enable mongod 
systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Enabling and starting mongod"



