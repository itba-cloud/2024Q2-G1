module "vpc_interno" {
  source  = "./modules/vpc_interno"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  cant_AZ  = var.cant_AZ
  subnets  = [
    for i in range(var.cant_AZ) : {
      name              = "${var.vpc_name}-subnet-${i+1}"
      availability_zone = data.aws_availability_zones.available.names[i]
    }
  ]
}

module "dynamoQuejas" {
  source        = "./modules/dynamo"
  table_name    = "quejasVecinos"
  hash_key      = "pk_urg"
  range_key     = "sk_tipo_id"
  read_capacity = 1
  write_capacity = 1
  tags          = {
    Name = "DynamoQuejasVecinos"
  }
}

#Agregar un registro a la DynamoDB
resource "aws_dynamodb_table_item" "queja_jardineria" {
  table_name = module.dynamoQuejas.table_name
  hash_key   = "pk_urg"
  range_key  = "sk_tipo_id"

  item = <<ITEM
  {
    "pk_urg": {"S": "URG#ALTA"},
    "sk_tipo_id": {"S": "TIPO#JARDINERÍA#9cf10a83-6374-42b6-be67-asdasdd"},
    "detalle": {"S": "iaisjdab"},
    "estado": {"S": "PENDIENTE"},
    "fecha": {"S": "2024-10-10"},
    "idDenuncia": {"S": "9cf10a83-6374-42b6-be67-8d6c252f41e4"},
    "nombre_propietario": {"S": "Fede Capo"},
    "tipo": {"S": "JARDINERÍA"},
    "titulo": {"S": "laksjdlkj"},
    "urgencia": {"S": "ALTA"}
  }
  ITEM
}

module "dynamoReservas" {
  source        = "./modules/dynamo"
  table_name    = "reservasVecinos"
  hash_key      = "pk_fecha"
  range_key     = "sk_espacio_reserva"
  read_capacity = 1
  write_capacity = 1
  tags          = {
    Name = "DynamoReservaCanchas"
  }
}

module "dynamoEntradas" {
  source        = "./modules/dynamo"
  table_name    = "entradasVisitantes"
  hash_key      = "pk"
  range_key     = "sk"
  read_capacity = 1
  write_capacity = 1
  tags          = {
    Name = "DynamoEntradasVisitantes"
  }
}

module "alerta_dynamo" {
  sns_name               = "sns_dynamo_admin"
  source                 = "./modules/alerta_dynamo"
  email_endpoint         = var.mail_admin
  lambda_name            = "quejasSNS"
  lambda_role_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  lambda_filename        = "output_lambda_functions/quejasSNS_src.zip"
  lambda_source_code_hash = data.archive_file.quejasSNS_code.output_base64sha256
  dynamo_stream_arn      = module.dynamoQuejas.stream_arn
  lambda_handler = "quejasSNS.lambda_handler"
  otro_sns_arn = module.alerta_dynamo_reservas.sns_topic_arn
}

module "alerta_dynamo_reservas" {
  sns_name               = "sns_dynamo_general"
  source                 = "./modules/alerta_dynamo"
  email_endpoint         = var.mail_admin
  lambda_name            = "reservasSNS"
  lambda_role_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  lambda_filename        = "output_lambda_functions/reservasSNS_src.zip"
  lambda_source_code_hash = data.archive_file.reservasSNS_code.output_base64sha256
  dynamo_stream_arn      = module.dynamoReservas.stream_arn
  lambda_handler = "reservasSNS.lambda_handler"
}

module "cognito" {
  source                  = "./modules/cognito"
  user_pool_name          = "nombreuserpoolrandom"
  verification_email_subject = "Verifica tu cuenta en Sistema Quejas Vecinos"
  verification_email_message = "Gracias por registrarte. Para verificar tu cuenta, usa este código: {####}."
  user_pool_client_name   = "cliente-user-pool-plataforma"
  callback_urls           = ["${module.api_gateway.api_url}/redirectBucket"]
  logout_urls             = ["${module.api_gateway.api_url}/redirectBucket"]
  cognito_domain          = var.nombre_cognito
  api_gateway_rest_api_id = module.api_gateway.api_id
  region                  = "us-east-1"  # o la región que necesites
  account_id              = data.aws_caller_identity.current.account_id
  lambda_subscribe_sns =  aws_lambda_function.subscribe_user_to_sns.arn
}
 
resource "aws_security_group" "lambda_sg" {
  name        = "Lambda-sg-Terra"
  description = "SG hecho en terra para las lambdas"
  vpc_id      = module.vpc_interno.vpc_id  
  # Reglas de Inbound: No se definen para dejarlo sin reglas de entrada
  # Reglas de Outbound: HTTPS (puerto 443) con destino 0.0.0.0/0
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-lambdas-terraform"
  }
}

resource "aws_lambda_function" "get_denuncia" {
  function_name = "getDenuncia"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "getDenuncia.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_getDenuncia_src.zip"
  source_code_hash = data.archive_file.get_denuncia_code.output_base64sha256
  depends_on = [ module.vpc_interno ]

  vpc_config {
    subnet_ids         = flatten([module.vpc_interno.subnet_ids])
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_lambda_function" "post_denuncia" {
  function_name = "postDenuncia"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "postDenuncia.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_postDenuncia_src.zip"
  source_code_hash = data.archive_file.post_denuncia_code.output_base64sha256
  depends_on = [ module.vpc_interno ]
  vpc_config {
    subnet_ids         = flatten([module.vpc_interno.subnet_ids])
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_lambda_function" "get_entrada" {
  function_name = "getEntrada"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "getEntrada.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_getEntrada_src.zip"
  source_code_hash = data.archive_file.get_entrada_code.output_base64sha256
  depends_on = [ module.vpc_interno ]

  vpc_config {
    subnet_ids         = flatten([module.vpc_interno.subnet_ids])
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_lambda_function" "post_entrada" {
  function_name = "postEntrada"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "postEntrada.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_postEntrada_src.zip"
  source_code_hash = data.archive_file.post_entrada_code.output_base64sha256
  depends_on = [ module.vpc_interno ]
  vpc_config {
    subnet_ids         = flatten([module.vpc_interno.subnet_ids])
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_lambda_function" "edit_entrada" {
  function_name = "editEntrada"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "editEntrada.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_editEntrada_src.zip"
  source_code_hash = data.archive_file.edit_entrada_code.output_base64sha256
  depends_on = [ module.vpc_interno ]
  vpc_config {
    subnet_ids         = flatten([module.vpc_interno.subnet_ids])
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_lambda_function" "add_reserva" {
  function_name = "addReserva"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "addReserva.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_addReserva_src.zip"
  source_code_hash = data.archive_file.addReserva_code.output_base64sha256
  depends_on = [ module.vpc_interno ]
  vpc_config {
    subnet_ids         = flatten([module.vpc_interno.subnet_ids])
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_lambda_function" "get_reserva" {
  function_name = "getReserva"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "getReserva.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_getReserva_src.zip"
  source_code_hash = data.archive_file.getReserva_code.output_base64sha256
  depends_on = [ module.vpc_interno ]
  vpc_config {
    subnet_ids         = flatten([module.vpc_interno.subnet_ids])
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

resource "aws_lambda_function" "presigned_url" {
  function_name = "presignedUrl"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "presignedUrl.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_presignedUrl_src.zip"
  source_code_hash = data.archive_file.presignedUrl_code.output_base64sha256
  depends_on = [ module.vpc_interno ]
  environment {
    variables = {
      BUCKET_NAME = module.s3_bucket_presigned.bucket_bucket
    }
  } 
}

resource "aws_lambda_function" "redirect" {
  function_name = "redirect"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "redirect.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename = "output_lambda_functions/lambda_redirect_src.zip"
  source_code_hash = data.archive_file.redirect_code.output_base64sha256
  depends_on = [ module.vpc_interno ]
  environment {
    variables = {
      REDIRECT_URL = module.s3_static_site.bucket_website_endpoint
    }
  }
}

module "api_gateway" {
  source                     = "./modules/apigateway"
  api_name                   = "apiVecinos"
  api_description            = "API de Terraform para quejas de vecinos"
  cognito_authorizer_id      = module.cognito.authorizer_id
  getImagen_lambda_uri       = aws_lambda_function.presigned_url.invoke_arn
  get_lambda_uri             = aws_lambda_function.get_denuncia.invoke_arn
  getEntrada_lambda_uri      = aws_lambda_function.get_entrada.invoke_arn
  editEntrada_lambda_uri     = aws_lambda_function.edit_entrada.invoke_arn
  postEntrada_lambda_uri     =  aws_lambda_function.post_entrada.invoke_arn
  getReservas_lambda_uri     = aws_lambda_function.get_reserva.invoke_arn
  post_lambda_uri            = aws_lambda_function.post_denuncia.invoke_arn
  postReservas_lambda_uri    = aws_lambda_function.add_reserva.invoke_arn
  redirect_lambda_uri        = aws_lambda_function.redirect.invoke_arn
  getImagen_lambda_function_name = aws_lambda_function.presigned_url.function_name
  getEntrada_lambda_function_name = aws_lambda_function.get_entrada.function_name
  editEntrada_lambda_function_name = aws_lambda_function.edit_entrada.function_name
  get_lambda_function_name   = aws_lambda_function.get_denuncia.function_name
  getReservas_lambda_function_name   = aws_lambda_function.get_reserva.function_name
  post_lambda_function_name  = aws_lambda_function.post_denuncia.function_name
  postReservas_lambda_function_name  = aws_lambda_function.add_reserva.function_name
  postEntrada_lambda_function_name = aws_lambda_function.post_entrada.function_name
  redirect_lambda_function_name = aws_lambda_function.redirect.function_name
  stage_name                 = "prod"
}

module "s3_static_site" {
  source           = "./modules/static_site"  # Ruta hacia el módulo
  nombre_bucket    = var.nombre_bucket   # Variable que ya debería estar definida
  bucket_name_tag  = "Front sistema vecinos" # Puedes cambiar estos valores si necesitas
  environment_tag  = "Prod"
}

module "s3_static_site_formulario" {
  source           = "./modules/static_site"  # Ruta hacia el módulo
  nombre_bucket    = var.nombre_bucket_formulario   # Variable que ya debería estar definida
  bucket_name_tag  = "Front formulario visitas" # Puedes cambiar estos valores si necesitas
  environment_tag  = "Prod"
}


# Subir el archivo index.html del formulario de visitas
resource "aws_s3_object" "index_html" {
  bucket = module.s3_static_site_formulario.bucket_name
  key    = "index.html"
  source = "web_formulario/index.html"  # Ruta local del archivo
  content_type = "text/html"
}

# Subir el archivo index.html del sistema
resource "aws_s3_object" "index_html_formulario" {
  bucket = module.s3_static_site.bucket_name
  key    = "index.html"
  source = "web/index.html"  # Ruta local del archivo
  content_type = "text/html"
}

resource "aws_lambda_function" "subscribe_user_to_sns" {
  filename         = "output_lambda_functions/lambda_subscribeSNS_src.zip"  # Cambia este archivo por el código comprimido de tu Lambda
  function_name    = "sns_subscribe"
  handler          = "subscribeSNS.lambda_handler"
  runtime          = "python3.9"
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  source_code_hash =  data.archive_file.subscribeSNS_code.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN_SUB = module.alerta_dynamo_reservas.sns_topic_arn
    }
  }
}

resource "aws_lambda_permission" "allow_cognito_invoke" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe_user_to_sns.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito.user_pool_arn
}

module "s3_bucket_presigned" {
  source      = "./modules/s3_bucket_presigned"
  bucket_name = var.bucket_imagenes
}
