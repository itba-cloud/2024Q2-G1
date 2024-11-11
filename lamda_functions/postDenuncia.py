import json
import boto3 # type: ignore
import uuid
from datetime import datetime

# Inicializa el cliente de DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = 'quejasVecinos'
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Parsear el cuerpo de la solicitud desde el evento (en formato JSON string)
        body = json.loads(event['body'])  # Asegúrate de extraer el cuerpo correctamente
        
        # Obtener los datos del cuerpo de la solicitud
        urgencia = body['urgencia']
        tipo = body['tipo']
        nombre_propietario = body['nombre_propietario']
        titulo = body['titulo']
        detalle = body['detalle']        

        # Obtener el email del usuario desde el token de identidad de Cognito
        email_usuario = event['requestContext']['authorizer']['claims']['email']
        
        # Crear el idDenuncia automáticamente (UUID)
        idDenuncia = str(uuid.uuid4())
        
        # Crear el formato de fecha actual
        fecha = datetime.now().strftime("%Y-%m-%d")
        
        # Definir estado
        estado = "PENDIENTE"
        
        # Definir la clave primaria (PK y SK) y los demás atributos
        item = {
            'pk_urg': f"URG#{urgencia}",
            'sk_tipo_id': f"TIPO#{tipo}#{idDenuncia}",
            'urgencia': urgencia,
            'tipo': tipo,
            'fecha': fecha,
            'idDenuncia': idDenuncia,
            'nombre_propietario': nombre_propietario,
            'titulo': titulo,
            'detalle': detalle,
            'estado': estado,
            'mail': email_usuario
        }
        
        # Insertar el ítem en la tabla DynamoDB
        table.put_item(Item=item)
        
        # Respuesta exitosa
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Datos insertados exitosamente',
                'data': item
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
