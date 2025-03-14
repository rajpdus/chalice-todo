from chalice import Chalice, Response
from chalice import BadRequestError, NotFoundError
import boto3
import os
import uuid
from datetime import datetime

app = Chalice(app_name='todo-app')
app.debug = True

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')

# Get the DynamoDB table name from environment variable or use default
TABLE_NAME = os.environ.get('TODO_TABLE_NAME', 'todo-app-tasks')
table = dynamodb.Table(TABLE_NAME)

# Add a debug log to show the table name
app.log.debug(f"Using DynamoDB table: {TABLE_NAME}")

@app.route('/')
def index():
    return {'app': 'todo-app', 'version': '1.0.0'}

@app.route('/todos', methods=['GET'])
def get_all_todos():
    """Get all todo items"""
    response = table.scan()
    return {'todos': response.get('Items', [])}

@app.route('/todos', methods=['POST'])
def create_todo():
    """Create a new todo item"""
    request_data = app.current_request.json_body
    if not request_data or 'title' not in request_data:
        raise BadRequestError('Title is required')
    
    # Create a new todo item
    current_time = datetime.utcnow().isoformat()
    todo_id = str(uuid.uuid4())
    
    item = {
        'id': todo_id,
        'title': request_data['title'],
        'description': request_data.get('description', ''),
        'completed': request_data.get('completed', False),
        'createdAt': current_time,
        'updatedAt': current_time
    }
    
    # Save to DynamoDB
    table.put_item(Item=item)
    return item

@app.route('/todos/{todo_id}', methods=['GET'])
def get_todo(todo_id):
    """Get a specific todo item by ID"""
    response = table.get_item(Key={'id': todo_id})
    item = response.get('Item')
    if not item:
        raise NotFoundError(f"Todo with id '{todo_id}' not found")
    return item

@app.route('/todos/{todo_id}', methods=['PUT'])
def update_todo(todo_id):
    """Update a todo item"""
    request_data = app.current_request.json_body
    if not request_data:
        raise BadRequestError('No data provided for update')
    
    # Check if todo exists
    response = table.get_item(Key={'id': todo_id})
    if 'Item' not in response:
        raise NotFoundError(f"Todo with id '{todo_id}' not found")
    
    # Update fields
    update_expression = []
    expression_attribute_values = {}
    expression_attribute_names = {}
    
    # Fields that can be updated
    updatable_fields = {
        'title': 'title',
        'description': 'description',
        'completed': 'completed'
    }
    
    for key, attr_name in updatable_fields.items():
        if key in request_data:
            update_expression.append(f"#{attr_name} = :{attr_name}")
            expression_attribute_values[f":{attr_name}"] = request_data[key]
            expression_attribute_names[f"#{attr_name}"] = attr_name
    
    # Add updatedAt timestamp
    update_expression.append("#updatedAt = :updatedAt")
    expression_attribute_values[":updatedAt"] = datetime.utcnow().isoformat()
    expression_attribute_names["#updatedAt"] = "updatedAt"
    
    # Perform update
    update_expression_str = "SET " + ", ".join(update_expression)
    
    response = table.update_item(
        Key={'id': todo_id},
        UpdateExpression=update_expression_str,
        ExpressionAttributeValues=expression_attribute_values,
        ExpressionAttributeNames=expression_attribute_names,
        ReturnValues='ALL_NEW'
    )
    
    return response.get('Attributes', {})

@app.route('/todos/{todo_id}', methods=['DELETE'])
def delete_todo(todo_id):
    """Delete a todo item"""
    # Check if todo exists
    response = table.get_item(Key={'id': todo_id})
    if 'Item' not in response:
        raise NotFoundError(f"Todo with id '{todo_id}' not found")
    
    # Delete the item
    table.delete_item(Key={'id': todo_id})
    return Response(body={'message': f"Todo '{todo_id}' deleted successfully"},
                   status_code=200)

# The view function above will return {"hello": "world"}
# whenever you make an HTTP GET request to '/'.
#
# Here are a few more examples:
#
# @app.route('/hello/{name}')
# def hello_name(name):
#    # '/hello/james' -> {"hello": "james"}
#    return {'hello': name}
#
# @app.route('/users', methods=['POST'])
# def create_user():
#     # This is the JSON body the user sent in their POST request.
#     user_as_json = app.current_request.json_body
#     # We'll echo the json body back to the user in a 'user' key.
#     return {'user': user_as_json}
#
# See the README documentation for more examples.
#
