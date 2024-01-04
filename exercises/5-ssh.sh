#!/bin/bash

# Output file path
output_file="output.log"

# Redirect all subsequent output to the file
exec > $output_file 2>&1

# Create an SSH key pair
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPairViaCLI.pem

# Set appropriate permissions for the private key file
chmod 400 MyKeyPairViaCLI.pem

echo "SSH key pair created: MyKeyPairViaCLI"
