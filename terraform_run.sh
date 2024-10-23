#!/bin/bash

# Variables
outputFile="terraform_outputs.json"
logFile="terraform_run.log"

# Ejecuta Terraform init
echo "Iniciando Terraform..."
terraform init | tee -a $logFile

# Ejecuta Terraform apply
echo "Aplicando Terraform..."
terraform apply -auto-approve | tee -a $logFile

# Verifica si Terraform apply fue exitoso
if [ $? -ne 0 ]; then
    echo "Error al aplicar Terraform, revisa los logs en $logFile."
    exit 1
fi

# Obtiene los outputs en formato JSON y los guarda en un archivo
echo "Obteniendo outputs de Terraform..."
terraformOutputs=$(terraform output -json)
echo "$terraformOutputs" > $outputFile

# Verifica si los outputs se guardaron correctamente
if [ $? -eq 0 ]; then
    echo "Outputs guardados en $outputFile."
else
    echo "Error al guardar los outputs."
    exit 1
fi

# Variables para el archivo scripts.js
outputFile="web/scripts.js"
inputFile="web/base_scripts.js"
jsonFile="terraform_outputs.json"

# Lee el archivo JSON
jsonData=$(cat $jsonFile)
API_ENDPOINT=$(echo $jsonData | jq -r '.invoke_url.value')"/quejasVecinos"
REDIRECT_URL=$(echo $jsonData | jq -r '.invoke_url.value')"/redirectBucket"
userPoolId=$(echo $jsonData | jq -r '.user_pool_id.value')
bucketLink=$(echo $jsonData | jq -r '.website_url.value')
bucketLinkcode=$(echo $jsonData | jq -r '.website_url.value')"?code={code}"
cognito_domain="https://$(echo $jsonData | jq -r '.cognito_domain.value').auth.us-east-1.amazoncognito.com/oauth2/token"

# Variables que quieres agregar al inicio del archivo
variables=$(cat <<EOF
const API_ENDPOINT = "$API_ENDPOINT";
const REDIRECT_URL = "$REDIRECT_URL";
const userPoolId = "$userPoolId";
const COGNITO_DOMAIN = "$cognito_domain";
EOF
)

# Leer el contenido actual del archivo base_scripts.js
fileContent=$(cat $inputFile)

# Concatenar las nuevas variables al inicio del contenido del archivo
newContent="$variables
$fileContent"

# Sobrescribir el archivo scripts.js con el nuevo contenido
echo "$newContent" > $outputFile

# Mensaje de confirmación
echo "Variables agregadas exitosamente al inicio del archivo scripts.js."

subirScriptFile="subir_script.tf"

# Crear el archivo subir_script.tf
tfContent=$(cat <<EOF
# Subir el archivo scripts.js
resource "aws_s3_object" "scripts_js" {
  bucket = aws_s3_bucket.static_site.bucket
  key    = "scripts.js"
  source = "web/scripts.js"  # Ruta local del archivo
  content_type = "application/javascript"
}
EOF
)

# Escribir el contenido en subir_script.tf
echo "$tfContent" > $subirScriptFile

# Mensaje de confirmación
echo "Archivo subir_script.tf creado exitosamente."

lambdaRedirect="lamda_functions/redirect.py"

tfContent=$(cat <<EOF
import json
url = "$bucketLink"

def lambda_handler(event, context):
    # Extraer el code de los parámetros de la URL
    code = event['queryStringParameters'].get('code')
    
    if code:
        # Redirigir a la URL de S3 con el code
        redirect_url = f"http://{url}?code={code}"
    else:
        # Si no hay code, redirigir a la URL base o mostrar un error
        redirect_url = f"http://{url}"
    
    # Devolver la respuesta de redirección
    response = {
        "statusCode": 301,
        "headers": {
            "Location": redirect_url
        }
    }
    
    return response
EOF
)

# Escribir el contenido en subir_script.tf
echo "$tfContent" > $lambdaRedirect

# Ejecutar terraform apply para subir el archivo a S3
echo "Ejecutando terraform apply..."
terraform apply -auto-approve | tee -a $logFile

# Verificar si terraform apply fue exitoso
if [ $? -eq 0 ]; then
    echo "Terraform apply ejecutado exitosamente."
else
    echo "Error al ejecutar terraform apply. Revisa los logs en $logFile."
    exit 1
fi

# Verificar si el archivo scripts.js existe y eliminarlo
if [ -f $outputFile ]; then
    rm $outputFile
    echo "Archivo $outputFile eliminado exitosamente."
else
    echo "El archivo $outputFile no existe."
fi

# Verificar si el archivo subir_script.tf existe y eliminarlo
if [ -f $subirScriptFile ]; then
    rm $subirScriptFile
    echo "Archivo $subirScriptFile eliminado exitosamente."
else
    echo "El archivo $subirScriptFile no existe."
fi
