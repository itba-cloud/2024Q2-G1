import json
import boto3  # type: ignore
from datetime import datetime, timedelta
import uuid

# Conectar a DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = 'ReservasVecinosTerra'
table = dynamodb.Table(table_name)

# Lambda handler unificado
def lambda_handler(event, context):
    
    body = json.loads(event['body'])
    # Datos de la nueva reserva
    reserva_id = str(uuid.uuid4())
    fecha = body['fecha']
    espacio = body['espacio']
    horario = body['horario']

    # Obtener el email del usuario desde el token de identidad de Cognito
    email_usuario = event['requestContext']['authorizer']['claims']['email']
    
    # Convertir el horario a un objeto de tiempo
    horario_inicial = datetime.strptime(horario, '%H:%M')
    horario_final = horario_inicial + timedelta(hours=1)  # Duración de 1 hora

    # Verificar si existe una reserva en el mismo espacio y horario
    response = table.query(
        KeyConditionExpression="pk_fecha = :pk_fecha and begins_with(sk_espacio_reserva, :espacio_prefix)",
        ExpressionAttributeValues={
            ":pk_fecha": 'Fecha#' + fecha,
            ":espacio_prefix": 'Espacio#' + espacio
        }
    )
    
    # Comprobamos si hay alguna reserva para ese espacio y horario
    for item in response['Items']:
        # Convertir el horario de la reserva almacenada a un objeto de tiempo
        horario_reserva = datetime.strptime(item['Horario'], '%H:%M')
        horario_reserva_final = horario_reserva + timedelta(hours=1)  # Duración de 1 hora
        
        # Verificar si las reservas se solapan
        if (horario_inicial < horario_reserva_final and horario_final > horario_reserva):
            return {
                'statusCode': 409,
                'body': json.dumps({
                    'error': 'Conflicto: ya existe una reserva para este espacio en el horario especificado'                    
                }),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

    # Si no hay conflicto, procedemos a agregar la nueva reserva
    reserva_data = {
        # Definir la clave primaria (PK y SK) y los demás atributos
        'pk_fecha': 'Fecha#' + fecha,
        'sk_espacio_reserva': 'Espacio#' + espacio + '#Reserva#' + reserva_id,
        'ReservaID': reserva_id,
        'Fecha': fecha,
        'Espacio': espacio,
        'Horario': horario,
        'email': email_usuario
    }
    
    table.put_item(Item=reserva_data)
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'mensaje': 'Reserva agregada exitosamente',
            'reserva_id': reserva_id
        }),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }
