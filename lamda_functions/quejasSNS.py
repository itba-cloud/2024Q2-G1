import json
import boto3 # type: ignore
import os

# Crear el cliente de SNS
sns_client = boto3.client('sns')

# ARN del tema de SNS al que deseas enviar la información
SNS_TOPIC_ARN  = os.environ['SNS_TOPIC_ARN']
OTRO_SNS_TOPIC_ARN  = os.environ['OTRO_SNS']
MAIL_ADMIN = os.environ['ADMIN_MAIL']

print(SNS_TOPIC_ARN)
print(OTRO_SNS_TOPIC_ARN)
print(MAIL_ADMIN)

def lambda_handler(event, context):
    for record in event['Records']:
        # Verifica que el evento es de tipo "INSERT" o "MODIFY" para obtener los nuevos datos
        if record['eventName'] in ['INSERT', 'MODIFY']:
            # Obtiene los valores de las columnas 'sabor' y 'color'
            urgencia = record['dynamodb']['NewImage'].get('urgencia', {}).get('S', 'N/A')
            tipo = record['dynamodb']['NewImage'].get('tipo', {}).get('S', 'N/A')
            titulo = record['dynamodb']['NewImage'].get('titulo', {}).get('S', 'N/A')
            detalle = record['dynamodb']['NewImage'].get('detalle', {}).get('S', 'N/A')
            fecha = record['dynamodb']['NewImage'].get('fecha', {}).get('S', 'N/A')
            email = record['dynamodb']['NewImage'].get('mail', {}).get('S', 'N/A')
            nombre_propietario = record['dynamodb']['NewImage'].get('nombre_propietario', {}).get('S', 'N/A')
            
            # Crea el mensaje para SNS
            message = {
                'Urgencia': urgencia,
                'Tipo': tipo,
                'Titulo' : titulo,
                'Detalle': detalle,
                'Fecha': fecha,
                'Propietario': nombre_propietario
            }
            
            # Envía el mensaje al admin si es urgencia alta
            if urgencia == 'ALTA':
                message_attributes_admin = {}
                message_attributes_admin['userName'] = {
                    'DataType': 'String',
                    "StringValue": MAIL_ADMIN
                }
                sns_client.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Message=json.dumps(message),
                    Subject='RECLAMO VECINOS - URGENTE',
                    MessageAttributes=message_attributes_admin
                )
            
            # Envía el mensaje a SNS
            message_attributes = {}
            message_attributes['userName'] = {
                'DataType': 'String',
                "StringValue": email
             }
            sns_client.publish(
                TopicArn= OTRO_SNS_TOPIC_ARN,
                Message=json.dumps(message),
                Subject='RECLAMO REGISTRADO',
                MessageAttributes=message_attributes
            )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Eventos procesados con éxito')
    }
