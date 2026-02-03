#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER

if [ $USER_ID -ne 0 ]; then
    echo "$R Please run the script with Root user $N" | tee -a $LOGS_FILE
    exit 1
fi    


VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... :: $R FAILED $N" | tee -a $LOGS_FILE
    else 
        echo -e "$2 ... :: $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repods.d/rabbitmq.repo &>>$LOGS_FILE
VALIDATE $? "Copying the rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOGS_FILE
systemctl start rabbitmq-server
VALIDATE $? "enabling and starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
VALIDATE $? "created user and gien permissions"


