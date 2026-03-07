#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-06f23152b42979b41"  
INSTANCES=("mongodb" "frontend" "catalogue")
ZONE_ID="Z1033319ZTEWWV8J5PPG"
DOMAIN_NAME="anilkumar.shop"


for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro  --security-group-ids sg-06f23152b42979b41  --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi
        
    echo "$instance Ip is: $IP"

    aws route53 change-resource-record-sets --hosted-zone-id Z1033319ZTEWWV8J5PPG \
    --change-batch '{ 
        "Comment": "Creating or updating a record ser for cogninto endpoint",
        "Changes": [ { 
            "Action": "UPSERT",
            "ResourceRecordSet": { 
                "Name": "$RECORD_NAME",
                "Type": "A",
                "TTL": 1, 
                "ResourceRecords": [ { "Value": "'$IP'" } ]
        } 
        } ] 
    }'
done