# Proyecto de Plataforma para barrios privados

Este proyecto tiene como objetivo lanzar una infraestructura en AWS utilizando Terraform y otros componentes como API Gateway, Lambdas y Cognito. A continuación, se detallan los pasos para desplegar y acceder a los recursos creados.

## Funcionalidades de la plataforma

1. **Registro e inicio de sesión**
  - Los usuarios pueden registrarse con su correo electrónico en la plataforma y deberán validar ese correo con un mail de confirmación con código numérico.

2. **Gestión de quejas**
   - Los usuarios pueden cargar quejas de diferentes categorías (caminos, mantenimiento, jardinería, etc.) con un detalle, descripción e incluso una imagen ilustrativa.
   - Una vez cargado, los usuarios pueden ver las quejas registradas en el sistema.
   - Luego de cargar una queja, se les envía un mail de confirmación de que la misma fue correctamente registrada.
   - Si algún usuario sube una queja de urgencia ALTA, el sistema alerta a los administradores enviando un mail.
  
3. **Gestión de reservas de espacios**
   - Los usuarios pueden reservar espacios compartidos del barrio (SUM, cancha de fútbol, cancha de tenis).
   - También pueden ver las reservas ya registradas.
   - Las reservas tienen limitaciones temporarias, no se pueden pisar entre si, solo puede reservarse entre las 8am y las 22 horas y además deben ser reservas hacia adelante.
   - El sistema envía una confirmación de reserva al correo del usuario luego de registrar una nueva.

  4. **Gestión de invitados y accesos**
     - El sistema facilita un formulario público para enviar a los invitados en el cual estos deberán ingresar sus datos, los datos de la visita y además el mail del propietario.
     - Cuando un invitado ingresa una solicitud de acceso, la misma le aparece al propietario en su plataforma (solo la puede ver él) y desde allí puede decidir si aceptarla o denegarla.
   
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

## Destruir la infraestructura

Para eliminar toda la infraestructura se debe ejecutar el siguiente código

```bash
   terraform destroy
