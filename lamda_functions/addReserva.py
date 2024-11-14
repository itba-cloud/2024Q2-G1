import json
import boto3  # type: ignore
from datetime import datetime, timedelta
import uuid

# Conectar a DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = 'reservasVecinos'
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
    
    # Convertir la fecha y horario a un objeto datetime completo para la reserva
    fecha_hora_reserva = datetime.strptime(f"{fecha} {horario}", '%Y-%m-%d %H:%M')
    fecha_hora_actual = datetime.now()
    
    # Verificar que la fecha y horario sean posteriores a la fecha y horario actual
    if fecha_hora_reserva <= fecha_hora_actual:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'La fecha y el horario de la reserva deben ser posteriores al momento actual'
            }),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    
    # Convertir el horario a un objeto de tiempo
    horario_inicial = datetime.strptime(horario, '%H:%M')
    horario_final = horario_inicial + timedelta(hours=1)  # Duración de 1 hora

    # Verificar que el horario esté entre las 8:00 y las 22:00
    inicio_permitido = datetime.strptime("08:00", "%H:%M").time()
    fin_permitido = datetime.strptime("22:00", "%H:%M").time()
    
    if not (inicio_permitido <= horario_inicial.time() < fin_permitido):
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'El horario de la reserva debe estar entre las 8:00 y las 22:00'
            }),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    
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
