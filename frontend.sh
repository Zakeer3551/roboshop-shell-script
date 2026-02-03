#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $LOGS_FOLDER

if [ $USER_ID -ne 0 ]; then
    echo "$R Please run the script with Root user $N" | tee -a $LOGS_FILE
    exit 1
else
    echo "$G Running the script with Root user $N" | tee -a $LOGS_FILE
fi    



VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... :: $R FAILED $N" | tee -a $LOGS_FILE
    else 
        echo -e "$2 ... :: $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nginx -y &>>$LOGS_FILE
dnf module enable nginx:1.24 -y &>>$LOGS_FILE
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"


systemctl enable nginx  &>>$LOGS_FILE
systemctl start nginx 
VALIDATE $? "Enabled and started nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded and unzipped frontend"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied our nginx conf file"

systemctl restart nginx
VALIDATE $? "Restarted Nginx"
