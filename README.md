# Proyecto de Infraestructura con Terraform

Este proyecto tiene como objetivo lanzar una infraestructura en AWS utilizando Terraform y otros componentes como API Gateway, Lambdas y Cognito. A continuación, se detallan los pasos para desplegar y acceder a los recursos creados.

## Arquitectura
<img width="576" src="https://github.com/user-attachments/assets/87f13efa-a9ea-412a-af1e-c7f274e58b74">

## Requisitos

Antes de lanzar la infraestructura, asegúrate de cumplir con los siguientes requisitos:

- Tener **AWS CLI** configurado con las credenciales correctas.
- Tener instalado **jq**, un paquete necesario para manipular JSON en bash.
- Tener instalado **Terraform** en tu máquina local.
- Clonar este repositorio en tu entorno local utilizando el comando `git clone`.

## Lanzar la Infraestructura en un entorno Linux

Para iniciar el despliegue de la infraestructura, sigue estos pasos:

1. **Clonar el repositorio:**
   
   ```bash
   git clone https://github.com/FedeAbancensITBA/2024Q2-G1.git
   ```

   Si todavía no fue aceptado el pull request deberán clonar la rama llamada "rama-entrega"
   
    ```bash
   git clone -b rama-entrega https://github.com/FedeAbancensITBA/2024Q2-G1.git
   ```
    
3. **Entrar a la carpeta que descarga del repositorio**
   
     ```bash
   cd 2024Q2-G1
   ```
     
4. **Modificar variables en terraform.tfvars**
Será necesario modificar las variables, principalmente aquellas vinculadas a nombres de recursos que deben ser únicos a nivel global

 ```bash
   nombre_cognito = <<DEBE SER ÚNICO A NIVEL GLOBAL>>
   nombre_bucket = <<DEBE SER ÚNICO A NIVEL GLOBAL>>
   bucket_imagenes = <<DEBE SER ÚNICO A NIVEL GLOBAL>>
   nombre_bucket_formulario = <<DEBE SER ÚNICO A NIVEL GLOBAL>>
   ```

4. **Dar permisos al script terraform_run.sh:**
   
   ```bash
   chmod +x terraform_run.sh
   
6. **Ejecutar el script:**
   
   ```bash
   ./terraform_run.sh
   
El script ejecutará los pasos necesarios para lanzar la infraestructura en AWS utilizando Terraform.

## Lanzar la Infraestructura en un entorno Windows

Para iniciar el despliegue de la infraestructura, sigue estos pasos:

1. **Clonar el repositorio:**
   
   ```bash
   git clone https://github.com/FedeAbancensITBA/TP-Terraform.git
   ```

   Si todavía no fue aceptado el pull request deberán clonar la rama llamada "rama-entrega"

    ```bash
   git clone -b rama-entrega https://github.com/FedeAbancensITBA/TP-Terraform.git
   ```
    
3. **Entrar a la carpeta que descarga del repositorio**
   
     ```bash
   cd 2024Q2-G1
   ```
     
4. **Modificar variables en terraform.tfvars**
Será necesario modificar las variables, principalmente aquellas vinculadas a nombres de recursos que deben ser únicos a nivel global

 ```bash
   nombre_cognito = <<DEBE SER ÚNICO A NIVEL GLOBAL>>
   nombre_bucket = <<DEBE SER ÚNICO A NIVEL GLOBAL>>
   bucket_imagenes = <<DEBE SER ÚNICO A NIVEL GLOBAL>>
   nombre_bucket_formulario = <<DEBE SER ÚNICO A NIVEL GLOBAL>>
   ```

4. **Dar permisos al script terraform_run.sh:**
   
   ```bash
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   
5. **Ejecutar el script:**
   
   ```bash
   ./terraform_script.ps1
   
El script ejecutará los pasos necesarios para lanzar la infraestructura en AWS utilizando Terraform.

## Acceder a la plataforma

Una vez que el script haya finalizado, verás un conjunto de outputs generados por Terraform. Busca el valor correspondiente a cognito_hosted_ui_url.

Este URL es el enlace para acceder a la interfaz alojada de Cognito. Simplemente copia el link y pégalo en tu navegador para acceder.


