import json
import boto3 # type: ignore
 
def lambda_handler(event, context):
    # Initialize a DynamoDB resource object for the specified region
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

    # Select the DynamoDB table named 'quejasVecinos'
    table = dynamodb.Table('entradasVisitantes')

    email_usuario = event['requestContext']['authorizer']['claims']['email']
    print(email_usuario)
    
    response = table.scan(
        FilterExpression="mailPropietario = :email",
        ExpressionAttributeValues={":email": email_usuario}
    )

    
    # Return the sorted data
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(response['Items'])  # La respuesta debe ser un string JSON
    }



