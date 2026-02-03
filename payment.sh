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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing python and other pacakges"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else 
    echo -e "User already exists ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "Creating app dir"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading the code"

cd /app 

rm -rf /app &>>$LOGS_FILE
VALIDATE $? "Removing the existing code"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? " unzipping the code "

cd /app 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "INstalling the dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOGS_FILE
VALIDATE $? "Creating systemcl service"

systemctl daemon-reload

systemctl enable payment &>>$LOGS_FILE
systemctl start payment
VALIDATE $? "Enabling and starting payment service"

