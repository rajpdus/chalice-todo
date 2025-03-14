#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the API endpoint URL
API_URL=$(aws cloudformation describe-stacks \
  --stack-name todo-app \
  --query "Stacks[0].Outputs[?OutputKey=='EndpointURL'].OutputValue" \
  --output text)

if [ -z "$API_URL" ]; then
  echo -e "${YELLOW}Could not find API endpoint URL. Is the stack deployed?${NC}"
  exit 1
fi

echo -e "${YELLOW}Testing API at ${API_URL}${NC}"

# Test the root endpoint
echo -e "\n${BLUE}Testing GET /${NC}"
curl -s "${API_URL}"

# Create a todo
echo -e "\n\n${BLUE}Creating a todo${NC}"
TODO_RESPONSE=$(curl -s -X POST "${API_URL}todos" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Todo", "description": "This is a test todo"}')

echo $TODO_RESPONSE | python -m json.tool

# Extract the todo ID
TODO_ID=$(echo $TODO_RESPONSE | python -c "import sys, json; print(json.load(sys.stdin)['id'])")

# Get all todos
echo -e "\n\n${BLUE}Getting all todos${NC}"
curl -s "${API_URL}todos" | python -m json.tool

# Get the specific todo
echo -e "\n\n${BLUE}Getting todo ${TODO_ID}${NC}"
curl -s "${API_URL}todos/${TODO_ID}" | python -m json.tool

# Update the todo
echo -e "\n\n${BLUE}Updating todo ${TODO_ID}${NC}"
curl -s -X PUT "${API_URL}todos/${TODO_ID}" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Todo", "completed": true}' | python -m json.tool

# Delete the todo
echo -e "\n\n${BLUE}Deleting todo ${TODO_ID}${NC}"
curl -s -X DELETE "${API_URL}todos/${TODO_ID}" | python -m json.tool

echo -e "\n\n${GREEN}API tests completed successfully!${NC}" 