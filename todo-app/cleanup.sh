#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if the stack exists before trying to delete it
STACK_EXISTS=$(aws cloudformation describe-stacks --stack-name todo-app 2>/dev/null || echo "STACK_NOT_FOUND")

if [[ $STACK_EXISTS == *"STACK_NOT_FOUND"* ]]; then
  echo -e "${YELLOW}Stack todo-app does not exist. Nothing to clean up.${NC}"
  exit 0
fi

echo -e "${YELLOW}Deleting CloudFormation stack...${NC}"
aws cloudformation delete-stack --stack-name todo-app

echo -e "${YELLOW}Waiting for stack deletion to complete...${NC}"
aws cloudformation wait stack-delete-complete --stack-name todo-app

echo -e "${RED}Cleanup complete!${NC}"

# Clean up generated files
echo -e "${YELLOW}Cleaning up generated files...${NC}"
rm -f .chalice/cloudformation/sam.json
rm -f .chalice/cloudformation/deployment.zip
rm -f .chalice/cloudformation/layer-deployment.zip

echo -e "${RED}All cleaned up!${NC}" 