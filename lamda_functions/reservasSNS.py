import json
import boto3 # type: ignore
import os

# Crear el cliente de SNS
sns_client = boto3.client('sns')

# ARN del tema de SNS al que deseas enviar la información
SNS_TOPIC_ARN  = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    for record in event['Records']:
        # Verifica que el evento es de tipo "INSERT" o "MODIFY" para obtener los nuevos datos
        if record['eventName'] in ['INSERT', 'MODIFY']:
            # Obtiene los valores de las columnas 'sabor' y 'color'
            email = record['dynamodb']['NewImage'].get('email', {}).get('S', 'N/A')
            fecha = record['dynamodb']['NewImage'].get('Fecha', {}).get('S', 'N/A')
            espacio = record['dynamodb']['NewImage'].get('Espacio', {}).get('S', 'N/A')
            horario = record['dynamodb']['NewImage'].get('Horario', {}).get('S', 'N/A')
          
            # Crea el mensaje para SNS
            message = {
                'Espacio': espacio,
                'Fecha' : fecha,
                'Horario': horario,
            }
            
            # Envía el mensaje a SNS
            message_attributes = {}
            message_attributes['userName'] = {
                'DataType': 'String',
                "StringValue": email
             }
            sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=json.dumps(message),
                Subject='CONFIRMACION RESERVA',
                MessageAttributes=message_attributes
            )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Eventos procesados con éxito')
    }
