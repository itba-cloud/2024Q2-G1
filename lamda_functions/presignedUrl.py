import boto3 # type: ignore
import uuid
import os
import json

s3_client = boto3.client('s3')
bucket_name = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    # Genera un ID único para el archivo y la entrada de DynamoDB
    unique_id = str(uuid.uuid4())
    file_name = f"{unique_id}.jpg"  # Suponiendo que sea una imagen JPG

    # Genera la URL presignada para S3
    presigned_url = s3_client.generate_presigned_url(
    'put_object',
    Params={
        'Bucket': bucket_name,
        'Key': file_name,
        'ContentType': 'image/jpeg'  # Define el tipo de contenido, como 'image/jpeg' o 'image/png'
    },
    ExpiresIn=3600  # Expiración en 1 hora
)


    # Devuelve la URL presignada y el ID único
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({
            "presigned_url": presigned_url,
            "unique_id": unique_id,
            "file_name": file_name
        })
    }
