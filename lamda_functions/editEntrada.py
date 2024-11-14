import boto3 # type: ignore
from boto3.dynamodb.conditions import Key # type: ignore
import json

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('entradasVisitantes')  # Cambia por el nombre de tu tabla

def lambda_handler(event, context):
    body = json.loads(event['body'])
    pk = body['pk']
    sk = body['sk']
    nuevo_estado = body['nuevo_estado']

    # Actualizar el estado en DynamoDB
    response = table.update_item(
        Key={
            'pk': pk,
            'sk': sk
        },
        UpdateExpression="SET estado = :estado",
        ExpressionAttributeValues={
            ':estado': nuevo_estado
        },
        ReturnValues="UPDATED_NEW"
    )

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Estado actualizado correctamente',
            'nuevo_estado': response['Attributes']['estado']
        }),
        'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            } 
    }
