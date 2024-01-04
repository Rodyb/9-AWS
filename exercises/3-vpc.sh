#!/bin/bash
#
vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.0.0/24 --query 'Subnet.SubnetId' --output text)

security_group_id=$(aws ec2 create-security-group \
  --group-name NodeAppSecurityGroup \
  --description "Security group for Node.js application" \
  --vpc-id $vpc_id \
  --output text --query 'GroupId')

# Authorize inbound rules for SSH to only be accessible for myself
aws ec2 authorize-security-group-ingress \
  --group-id $security_group_id \
  --protocol tcp --port 22 \
  --cidr 82.75.51.127/32

# Authorize inbound rules for the node app
aws ec2 authorize-security-group-ingress \
  --group-id $security_group_id \
  --protocol tcp --port 8080 \
  --cidr 0.0.0.0/0

aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=VpcForNode
