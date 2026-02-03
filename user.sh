#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD


if [ $USER_ID -ne 0 ]; then
    echo "$R Please run the script with Root user $N" | tee -a $LOGS_FILE
    exit 1
fi    

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... :: $R FAILED $N" | tee -a $LOGS_FILE
    else 
        echo -e "$2 ... :: $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling Nodejs default version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling Nodejs 20 version"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installing Nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else 
    echo -e " Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downlaoding User application code"
cd /app 

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping the user application"

cd /app 
npm install &>>$LOGS_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOGS_FILE
VALIDATE $? "Copy the systemctl service"

systemctl daemon-reload
VALIDATE $? "Daemon reload"

systemctl enable user 
systemctl start user &>>$LOGS_FILE
VALIDATE $? "Enablinf and starting the user"




