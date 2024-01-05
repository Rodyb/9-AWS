#!/bin/bash

# Security Group Name
SECURITY_GROUP_NAME="security-group-docker-server"
export DIGITAL_OCEAN_IP=$1

# Get the Security Group ID based on its name
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --group-names "${SECURITY_GROUP_NAME}" --query 'SecurityGroups[0].GroupId' --output text)

# Check if the security group ID is obtained successfully
if [ -z "$SECURITY_GROUP_ID" ]; then
    echo "Error: Unable to retrieve Security Group ID for '${SECURITY_GROUP_NAME}'. Please check the security group name."
    exit 1
fi

# Check if port 3000 is already open in the security group
EXISTING_RULE=$(aws ec2 describe-security-groups --group-id "${SECURITY_GROUP_ID}" | jq -e '.SecurityGroups[0].IpPermissions[] | select(.ToPort == 3000)' > /dev/null && echo "true" || echo "false")

if [ "$EXISTING_RULE" == "true" ]; then
    echo "Port 3000 is already open in the security group."
else
    echo "Port 3000 is not open in the security group. Adding rule..."
    export AWS_PAGER=""

    aws ec2 authorize-security-group-ingress \
        --group-id "${SECURITY_GROUP_ID}" \
        --protocol tcp \
        --port 3000 \
        --cidr "${DIGITAL_OCEAN_IP}"/32

    echo "Rule added for port 3000."
fi
