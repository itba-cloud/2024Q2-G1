import json

def lambda_handler(event, context):
    # Extraer el code de los parámetros de la URL
    code = event['queryStringParameters'].get('code')
    
    if code:
        # Redirigir a la URL de S3 con el code
        redirect_url = f"http://otrobaldedefede.s3-website-us-east-1.amazonaws.com?code={code}"
    else:
        # Si no hay code, redirigir a la URL base o mostrar un error
        redirect_url = "http://otrobaldedefede.s3-website-us-east-1.amazonaws.com"
    
    # Devolver la respuesta de redirección
    response = {
        "statusCode": 301,
        "headers": {
            "Location": redirect_url
        }
    }
    
    return response
