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

outputFile2="web_formulario/scripts.js"
inputFile2="web_formulario/base_scripts.js"

# Lee el archivo JSON
jsonData=$(cat $jsonFile)
API_ENDPOINT=$(echo $jsonData | jq -r '.invoke_url.value')
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

# Leer el contenido actual del archivo base_scripts.js
fileContent2=$(cat $inputFile2)

# Concatenar las nuevas variables al inicio del contenido del archivo
newContent2="$variables2
$fileContent2"

# Sobrescribir el archivo scripts.js con el nuevo contenido
echo "$newContent2" > $outputFile2

# Mensaje de confirmación
echo "Variables agregadas exitosamente al inicio del archivo scripts.js."

subirScriptFile="subir_script.tf"

# Crear el archivo subir_script.tf
tfContent=$(cat <<EOF
# Subir el archivo scripts.js
resource "aws_s3_object" "scripts_js" {
  bucket = module.s3_static_site.bucket_name
  key    = "scripts.js"
  source = "web/scripts.js"  # Ruta local del archivo
  content_type = "application/javascript"
}

# Subir el archivo scripts.js
resource "aws_s3_object" "scripts_js_formulario" {
  bucket = module.s3_static_site_formulario.bucket_name
  key    = "scripts.js"
  source = "web_formulario/scripts.js"  # Ruta local del archivo
  content_type = "application/javascript"
}
EOF
)

# Escribir el contenido en subir_script.tf
echo "$tfContent" > $subirScriptFile

# Mensaje de confirmación
echo "Archivo subir_script.tf creado exitosamente."

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

# Verificar si el archivo scripts.js existe y eliminarlo
if [ -f $outputFile2 ]; then
    rm $outputFile2
    echo "Archivo $outputFile2 eliminado exitosamente."
else
    echo "El archivo $outputFile2 no existe."
fi

# Verificar si el archivo subir_script.tf existe y eliminarlo
if [ -f $subirScriptFile ]; then
    rm $subirScriptFile
    echo "Archivo $subirScriptFile eliminado exitosamente."
else
    echo "El archivo $subirScriptFile no existe."
fi
