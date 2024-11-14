import json
import boto3 # type: ignore
import uuid
from datetime import datetime

# Inicializa el cliente de DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = 'entradasVisitantes'
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Parsear el cuerpo de la solicitud desde el evento (en formato JSON string)
        body = json.loads(event['body'])  # Asegúrate de extraer el cuerpo correctamente        
        nombre_visitante = body['nombreVisitante']
        documento_visitante = body['documentoVisitante']
        fecha_ingreso = body['fechaIngreso']
        hora_ingreso = body['horaIngreso']
        mail_propietario = body['mailPropietario']
        
        auth_id = str(uuid.uuid4())
        
        fecha_creacion = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        item = {
            'pk': 'Propietario#' + mail_propietario,
            'sk': 'Fecha#' + fecha_creacion + '#' + auth_id,
            'id': auth_id,
            'nombreVisitante': nombre_visitante,
            'documentoVisitante': documento_visitante,
            'fechaIngreso': fecha_ingreso,
            'horaIngreso': hora_ingreso,
            'mailPropietario': mail_propietario,
            'fechaCreacion': fecha_creacion,
            'estado': 'Pendiente'  # Estado inicial de la autorización
        }
        
        table.put_item(Item=item)
        # Respuesta exitosa
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Datos insertados exitosamente',
                'id': auth_id
            }),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            } 
        }
    except Exception as e:
        # En caso de error
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error al insertar los datos',
                'error': str(e)
            }),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
