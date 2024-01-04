#!/bin/bash

AWS_CLI_PATH=$(which aws)
# Security Group Name
SECURITY_GROUP_NAME="security-group-docker-server"
DIGITAL_OCEAN_IP=$1
echo $DIGITAL_OCEAN_IP

# Get the Security Group ID based on its name
SECURITY_GROUP_ID=$($AWS_CLI_PATH ec2 describe-security-groups --group-names "${SECURITY_GROUP_NAME}" --query 'SecurityGroups[0].GroupId' --output text)

# Check if the security group ID is obtained successfully
if [ -z "$SECURITY_GROUP_ID" ]; then
    echo "Error: Unable to retrieve Security Group ID for '${SECURITY_GROUP_NAME}'. Please check the security group name."
    exit 1
fi

# AWS CLI command to modify the inbound rules of the security group
$AWS_CLI_PATH ec2 authorize-security-group-ingress \
    --group-id "${SECURITY_GROUP_ID}" \
    --protocol tcp \
    --port 3000 \
    --cidr ${DIGITAL_OCEAN_IP}/32
