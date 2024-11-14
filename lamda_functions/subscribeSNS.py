import boto3  # type: ignore
import os
import json

sns_client = boto3.client('sns')
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN_SUB')

def lambda_handler(event, context):
    email_usuario = event['request']['userAttributes']['email']

    try:
        # Verificar si el usuario ya está suscrito
        response = sns_client.list_subscriptions_by_topic(TopicArn=SNS_TOPIC_ARN)
        for subscription in response['Subscriptions']:
            if subscription['Endpoint'] == email_usuario:
                # El usuario ya está suscrito; no es necesario hacer nada
                return event
        
        # Suscribir al usuario si no está en la lista
        subscription_response = sns_client.subscribe(
            TopicArn=SNS_TOPIC_ARN,
            Protocol='email',
            Endpoint=email_usuario,
            Attributes={
                'FilterPolicy': json.dumps({
                    'userName': [email_usuario]
                })
            }
        )
                
        return event
    except Exception as e:
        # Manejar errores y loggear, pero retornar un objeto vacío
        print(f"Error al suscribir al usuario: {str(e)}")
        return event
