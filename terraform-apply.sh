#!/bin/bash

set +x
# set -e


if [ "$#" -lt 1 ]; then
    script_name=$(basename "$0")
    echo "Usage:   ${script_name} <input-file-name>"
    echo "Example: ${script_name} example"
    exit -1
fi

WORKSPACE=$1

# Select/Create Terraform Workspace
terraform workspace select "${WORKSPACE}"
IS_WORKSPACE_PRESENT=$?
if [ "${IS_WORKSPACE_PRESENT}" -ne "0" ]
then
    terraform workspace new "${WORKSPACE}"
fi


terraform apply -var-file=settings/${WORKSPACE}.tfvars -auto-approve
