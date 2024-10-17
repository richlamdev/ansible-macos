#!/usr/bin/env bash

# requirement
# pip install aws-mfa

#set -e
set -x

### Colors
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
###

### Args to parse
while getopts ":ha:r:e:" opt; do
  case ${opt} in
    h)
      echo "Usage:"
      echo "  -a The AWS_PROFILE inside of ${HOME}/.aws/config to use to assume a role."
      echo "  -r The role to be assumed."
      echo "  -e The environment (production, staging, infrastructure-lab) to assume role into."
      echo "Example:"
      echo "  ./aws_cli_environment_setup.sh -a default -r admin-role -e staging"
      echo "  This example command will use the default AWS profile to assume the admin role in staging."
      echo "Docs:"
      echo "  https://procurifydev.atlassian.net/wiki/spaces/LJ/pages/1741258768/AWS+IAM+Users"
      exit 0
      ;;
    a)
      export AWS_PROFILE="${OPTARG}"
      ;;
    r)
      ROLE_TO_ASSUME="${OPTARG}"
      ;;
    e)
      ENV_NAME="${OPTARG}"
      ;;
    \?)
      echo "Invalid option: ${OPTARG}" 1>&2
      exit 1
      ;;
    :)
      echo "-${OPTARG} requires an argument" 1>&2
      exit 1
      ;;
  esac
done

#### Validate args to parse
if [ -z "${AWS_PROFILE}" ]; then
  printf "${RED}AWS_PROFILE is not set. Please use -a flag. -h For usage.\n"
  exit 1
fi
if [ -z "${ROLE_TO_ASSUME}" ]; then
  printf "${RED}ROLE_TO_ASSUME is not set. Please use -r flag. -h For usage.\n"
  exit 1
fi
if [ -z "${ENV_NAME}" ]; then
  printf "${RED}ENV_NAME is not set. Please use -e flag. -h For usage.\n"
  exit 1
fi
####
###

### All procurify infrastructure is in us-west-2
export AWS_REGION=us-west-2
###

### Dependency validation
# if ! [ -x "$(command -v jq)" ]; then
#   echo "This script requires jq, please install it."
# fi
###

## default MFA setting
#export MFA_STS_DURATION=3600
export MFA_STS_DURATION=43200

# Script starts

## Based on the environment being worked on, set some variables for Vault and Account ID
if [[ "${ENV_NAME}" =~ "staging" ]]; then
  # export VAULT_ADDR=https://vault.procurify-staging.xyz
  export AWS_ACCOUNT_ID=584905272805
elif [[ "${ENV_NAME}" =~ "production" ]]; then
  # export VAULT_ADDR=https://vault.procurify.xyz
  export AWS_ACCOUNT_ID=146043269776
elif [[ "${ENV_NAME}" =~ "infrastructure-lab" ]]; then
  # export VAULT_ADDR=https://vault.procurify-infrastructure-lab.xyz
  export AWS_ACCOUNT_ID=217000254051
fi
##

## setup the ARN
AWS_ASSUME_ROLE="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_TO_ASSUME}"

## Delete the existing kube config.
export KUBERNETES_ROLE=$(echo $ROLE_TO_ASSUME | awk '{ print substr( $0, 1, length($0)-5 ) }')
[[ -f ${HOME}/.kube/config ]] && printf "${GREEN}Removing existing kube config.\n" && rm -rf ${HOME}/.kube/config
if [[ "${ENV_NAME}" =~ ^(staging|production|infrastructure-lab)$ ]]; then
  IAM_ROLE="kubernetes-${KUBERNETES_ROLE}-${ENV_NAME}"
fi
##

aws-mfa --duration ${MFA_STS_DURATION} --assume-role ${AWS_ASSUME_ROLE} --profile ${AWS_PROFILE}

# setup for AWS CLI access
export AWS_ACCESS_KEY_ID=$(grep "\[${AWS_PROFILE}\]" ~/.aws/credentials -A6 | grep "aws_access_key_id" | cut -f3 -d " ")
export AWS_SECRET_ACCESS_KEY=$(grep "\[${AWS_PROFILE}\]" ~/.aws/credentials -A6 | grep "aws_secret_access_key" | cut -f3 -d " ")
export AWS_SESSION_TOKEN=$(grep "\[${AWS_PROFILE}\]" ~/.aws/credentials -A6 | grep "aws_session_token" | cut -f3 -d " ")

### Write a new kube config after role has been assumed
aws eks update-kubeconfig --name "${ENV_NAME}" --role-arn arn:aws:iam::"$(aws sts get-caller-identity --output text --query 'Account')":role/"${IAM_ROLE}"

### export AWS environment to SHELL
export ENV_NAME
export AWS_PROFILE

###
printf "${GREEN}Starting a new shell.\n"
${SHELL}
