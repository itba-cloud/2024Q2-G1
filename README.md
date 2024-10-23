# Proyecto de Infraestructura con Terraform

Este proyecto tiene como objetivo lanzar una infraestructura en AWS utilizando Terraform y otros componentes como API Gateway, Lambdas y Cognito. A continuación, se detallan los pasos para desplegar y acceder a los recursos creados.

## Arquitectura

<img width="576" alt="Screenshot 2024-10-23 at 12 43 00" src="https://github.com/user-attachments/assets/611e266a-cc98-4759-9338-6c2f9d3f26e5">

## Requisitos

Antes de lanzar la infraestructura, asegúrate de cumplir con los siguientes requisitos:

- Tener **AWS CLI** configurado con las credenciales correctas.
- Tener instalado **jq**, un paquete necesario para manipular JSON en bash.

```bash
sudo apt-get update
sudo apt-get install jq
```

- Tener instalado **Terraform** en tu máquina local.
- Clonar este repositorio en tu entorno local utilizando el comando `git clone`.

## Lanzar la Infraestructura

Para iniciar el despliegue de la infraestructura, sigue estos pasos:

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/FedeAbancensITBA/TP-Terraform.git

2. **Modificar variables en terraform.tfvars**
Será necesario modificar las variables nombre_cognito y nombre_bucket dado que las mismas deben ser únicas a nivel global

4. **Dar permisos al script terraform_run.sh:**
   ```bash
   chmod +x terraform_run.sh
5. **Ejecutar el script:**
   ```bash
   ./terraform_run.sh

El script ejecutará los pasos necesarios para lanzar la infraestructura en AWS utilizando Terraform.

## Obtener la URL del Hosted UI de Cognito
Una vez que el script haya finalizado, verás un conjunto de outputs generados por Terraform. Busca el valor correspondiente a cognito_hosted_ui_url.

Este URL es el enlace para acceder a la interfaz alojada de Cognito. Simplemente copia el link y pégalo en tu navegador para acceder.


