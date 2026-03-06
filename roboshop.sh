#!/bin/bash


AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-06f23152b42979b41"  
INSTANCES=("mongodb" "frontend" "catalogue")
ZONE_ID="Z1033319ZTEWWV8J5PPG"
DOMAIN_NAME="anilkumar.shop"


for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro \
    --security-group-ids sg-06f23152b42979b41 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" \
    --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instance --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    
    else
        IP=$(aws ec2 describe-instance --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    
    fi
     
      echo "$instance Ip is: $IP" echo " $R $instance is : $instance"
 done