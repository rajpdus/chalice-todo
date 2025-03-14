# Chalice Todo API

A serverless Todo API built with AWS Chalice, using DynamoDB for storage and deployed with CloudFormation.

## Features

- Create, read, update, and delete Todo items
- Serverless architecture using AWS Lambda and API Gateway
- Data persistence with Amazon DynamoDB
- Infrastructure as Code using CloudFormation

## Prerequisites

- Python 3.7 or higher
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create Lambda, API Gateway, IAM roles, and DynamoDB resources

## Installation

1. Clone this repository
2. Install dependencies:

```bash
pip install -r requirements.txt
```

## Local Development

To run the application locally:

```bash
chalice local
```

This will start a local development server at http://localhost:8000.

## Deployment

### Deploy to AWS

To deploy the application to AWS:

```bash
./deploy.sh
```

This will:
1. Generate the Chalice CloudFormation template
2. Merge it with the additional resources defined in `aws_stack.yaml`
3. Deploy the merged stack to AWS
4. Output the API endpoint URL and DynamoDB table name

### Custom CloudFormation Resources

The application uses a separate CloudFormation template (`aws_stack.yaml`) to define additional resources:

- DynamoDB table for storing Todo items

This template is merged with the Chalice-generated template during deployment using Chalice's built-in `--merge-template` option.

### Generate CloudFormation Template

To generate a CloudFormation template without deploying:

```bash
chalice package --stage dev --merge-template aws_stack.yaml --template-format json .chalice/cloudformation
```

This will create a merged CloudFormation template in the `.chalice/cloudformation` directory that you can deploy using the AWS CloudFormation console or AWS CLI.

### Deploy using CloudFormation

To deploy using the merged CloudFormation template:

```bash
aws cloudformation deploy --template-file .chalice/cloudformation/sam.json --stack-name todo-app --capabilities CAPABILITY_IAM
```

## API Endpoints

- `GET /` - Get API information
- `GET /todos` - List all todos
- `POST /todos` - Create a new todo
- `GET /todos/{todo_id}` - Get a specific todo
- `PUT /todos/{todo_id}` - Update a todo
- `DELETE /todos/{todo_id}` - Delete a todo

## Example Usage

### Create a Todo

```bash
curl -X POST https://your-api-id.execute-api.region.amazonaws.com/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn AWS Chalice", "description": "Build a serverless API with Chalice"}'
```

### List All Todos

```bash
curl https://your-api-id.execute-api.region.amazonaws.com/api/todos
```

### Get a Specific Todo

```bash
curl https://your-api-id.execute-api.region.amazonaws.com/api/todos/{todo_id}
```

### Update a Todo

```bash
curl -X PUT https://your-api-id.execute-api.region.amazonaws.com/api/todos/{todo_id} \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated title", "completed": true}'
```

### Delete a Todo

```bash
curl -X DELETE https://your-api-id.execute-api.region.amazonaws.com/api/todos/{todo_id}
```

## Cleanup

To remove all AWS resources created by this application:

```bash
chalice delete
```

Or if you deployed using CloudFormation:

```bash
aws cloudformation delete-stack --stack-name todo-app
``` 