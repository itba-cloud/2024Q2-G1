import json
import boto3 # type: ignore

def lambda_handler(event, context):
    # Initialize a DynamoDB resource object for the specified region
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

    # Select the DynamoDB table named 'quejasVecinos'
    table = dynamodb.Table('quejasVecinos')

    # Scan the table to retrieve all items
    response = table.scan()
    data = response['Items']

    # If there are more items to scan, continue scanning until all items are retrieved
    while 'LastEvaluatedKey' in response:
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])

    # Define the order of urgency levels
    urgency_order = {'ALTA': 1, 'MEDIA': 2, 'BAJA': 3}

    # Sort the data based on the pk_urg value using the defined order
    sorted_data = sorted(data, key=lambda x: urgency_order.get(x['pk_urg'].split('#')[1], 4))

    # Return the sorted data
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(sorted_data)  # La respuesta debe ser un string JSON
    }



