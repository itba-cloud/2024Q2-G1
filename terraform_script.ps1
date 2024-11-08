Write-Output "Ejecutando versión actualizada"

# Variables
$outputFile = "terraform_outputs.json"
$logFile = "terraform_run.log"

# Instala JQ
Write-Output "Instalando JQ"
winget install jqlang.jq

# Ejecuta Terraform init
Write-Output "Iniciando Terraform..."
terraform init | Tee-Object -FilePath $logFile -Append

# Ejecuta Terraform apply
Write-Output "Aplicando Terraform..."
terraform apply -auto-approve | Tee-Object -FilePath $logFile -Append

# Verifica si Terraform apply fue exitoso
if ($LASTEXITCODE -ne 0) {
    Write-Output "Error al aplicar Terraform, revisa los logs en $logFile."
    exit 1
}

# Obtiene los outputs en formato JSON y los guarda en un archivo
Write-Output "Obteniendo outputs de Terraform..."
$terraformOutputs = terraform output -json
$terraformOutputs | Out-File -FilePath $outputFile

# Verifica si los outputs se guardaron correctamente
if ($LASTEXITCODE -eq 0) {
    Write-Output "Outputs guardados en $outputFile."
} else {
    Write-Output "Error al guardar los outputs."
    exit 1
}

# Variables para el archivo scripts.js
$outputFile = "web/scripts.js"
$inputFile = "web/base_scripts.js"
$jsonFile = "terraform_outputs.json"

# Lee el archivo JSON
$jsonData = Get-Content -Path $jsonFile | ConvertFrom-Json
$API_ENDPOINT = $jsonData.invoke_url.value
$REDIRECT_URL = $jsonData.invoke_url.value + "/redirectBucket"
$userPoolId = $jsonData.user_pool_id.value
$bucketLink = $jsonData.website_url.value
$bucketLinkcode = $jsonData.website_url.value + "?code={code}"
$cognito_domain = "https://" + $jsonData.cognito_domain.value + ".auth.us-east-1.amazoncognito.com/oauth2/token"

# Variables que quieres agregar al inicio del archivo
$variables = @"
const API_ENDPOINT = "$API_ENDPOINT";
const REDIRECT_URL = "$REDIRECT_URL";
const userPoolId = "$userPoolId";
const COGNITO_DOMAIN = "$cognito_domain";
"@

# Leer el contenido actual del archivo base_scripts.js
$fileContent = Get-Content -Path $inputFile -Raw

# Concatenar las nuevas variables al inicio del contenido del archivo
$newContent = $variables + "`n" + $fileContent

# Sobrescribir el archivo scripts.js con el nuevo contenido
$newContent | Out-File -FilePath $outputFile -Encoding UTF8

# Mensaje de confirmación
Write-Output "Variables agregadas exitosamente al inicio del archivo scripts.js."

$subirScriptFile = "subir_script2.tf"

# Crear el archivo subir_script.tf
$tfContent = @"
# Subir el archivo scripts.js
resource "aws_s3_object" "scripts_js" {
  bucket = module.s3_static_site.bucket_name
  key    = "scripts.js"
  source = "web/scripts.js"  # Ruta local del archivo
  content_type = "application/javascript"
}
"@

# Escribir el contenido en subir_script.tf
$tfContent | Out-File -FilePath $subirScriptFile -Encoding UTF8

# Mensaje de confirmación
Write-Output "Archivo subir_script.tf creado exitosamente."

# Ejecutar terraform apply para subir el archivo a S3
Write-Output "Ejecutando terraform apply..."
terraform apply -auto-approve | Tee-Object -FilePath $logFile -Append

# Verificar si terraform apply fue exitoso
if ($LASTEXITCODE -eq 0) {
    Write-Output "Terraform apply ejecutado exitosamente."
} else {
    Write-Output "Error al ejecutar terraform apply. Revisa los logs en $logFile."
    exit 1
}

# Verificar si el archivo scripts.js existe y eliminarlo
if (Test-Path -Path $outputFile) {
    Remove-Item -Path $outputFile
    Write-Output "Archivo $outputFile eliminado exitosamente."
} else {
    Write-Output "El archivo $outputFile no existe."
}

# Verificar si el archivo subir_script.tf existe y eliminarlo
if (Test-Path -Path $subirScriptFile) {
    Remove-Item -Path $subirScriptFile
    Write-Output "Archivo $subirScriptFile eliminado exitosamente."
} else {
    Write-Output "El archivo $subirScriptFile no existe."
}
