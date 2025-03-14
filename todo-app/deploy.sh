#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create directories if they don't exist
mkdir -p .chalice/cloudformation

echo -e "${YELLOW}Generating CloudFormation template with merged resources...${NC}"
chalice package --stage dev --merge-template aws_stack.yaml --template-format json .chalice/cloudformation

echo -e "${YELLOW}Deploying CloudFormation stack...${NC}"
aws cloudformation deploy \
  --template-file .chalice/cloudformation/sam.json \
  --stack-name todo-app \
  --capabilities CAPABILITY_IAM

echo -e "${YELLOW}Getting API endpoint URL...${NC}"
API_URL=$(aws cloudformation describe-stacks \
  --stack-name todo-app \
  --query "Stacks[0].Outputs[?OutputKey=='EndpointURL'].OutputValue" \
  --output text)

echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}API endpoint: ${API_URL}${NC}"

# Display table information
TABLE_NAME=$(aws cloudformation describe-stacks \
  --stack-name todo-app \
  --query "Stacks[0].Outputs[?OutputKey=='TodoTableName'].OutputValue" \
  --output text)

echo -e "${GREEN}DynamoDB Table: ${TABLE_NAME}${NC}" 