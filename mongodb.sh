#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then
    echo "Please run the script with Root user" | tee -a $LOG_FILE
    exit 1
elseif 
    echo "Running the script with Root user" | tee -a $LOG_FILE
fi    

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... :: $R FAILED $N" | tee -a $LOG_FILE
    elseif 
        echo -e "$2 ... :: $R SUCCESS $N" | tee -a $LOG_FILE
}

cp -p ./mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb server"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Allowing remote connections"

systemctl enable mongod 
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Enabling and starting mongod"



