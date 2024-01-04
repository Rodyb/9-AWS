#!/bin/bash

# Output file path
output_file="output.log"

# Create a log file
exec > $output_file 2>&1

# Create the a vpc with a subnet and security group, this is needed for the ec2 instance
vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.0.0/24 --query 'Subnet.SubnetId' --output text)

echo "Created VPC: $vpc_id"
echo "Created Subnet: $subnet_id"

security_group_id=$(aws ec2 create-security-group \
  --group-name NodeAppSecurityGroup5 \
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

# Add tags to the VPC for easier identification
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=VpcForNodeBlaat

# Add tags to the subnet for easier identification
aws ec2 create-tags --resources $subnet_id --tags Key=Name,Value=SubnetForNode

ami_id=$(aws ec2 describe-images \
  --region eu-central-1 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text)

instance_id=$(aws ec2 run-instances \
  --image-id ami-024f768332f080c5e \
  --count 1 \
  --instance-type t2.micro \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=myNodeInstance}]" \
  --key-name macbook \
  --security-group-ids $security_group_id \
  --subnet-id $subnet_id \
  --query 'Instances[0].InstanceId' \
  --output text)

exec >&-
