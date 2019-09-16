#!/bin/bash

set +x
set -e

if [ "$#" -lt 1 ]; then
    script_name=$(basename "$0")
    echo "Usage:   ${script_name} <input-file-name>"
    echo "Example: ${script_name} example"
    exit -1
fi

WORKSPACE=$1

# Select Terraform Workspace
terraform workspace select "${WORKSPACE}"

# Terraform Commands
terraform destroy -var-file=settings/${WORKSPACE}.tfvars
