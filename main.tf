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
  table_name    = "quejasVecinosTerra"
  hash_key      = "pk_urg"
  range_key     = "sk_tipo_id"
  read_capacity = 1
  write_capacity = 1
  tags          = {
    Name = "DynamoQuejasVecinos"
  }
}

module "alerta_dynamo" {
  source                 = "./modules/alerta_dynamo"
  email_endpoint         = "federicoabancens@gmail.com"
  lambda_name            = "dynamoStreamSNS"
  lambda_role_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  lambda_filename        = "output_lambda_functions/dynamoStreamSNS_src.zip"
  lambda_source_code_hash = data.archive_file.dynamoStreamSNS_code.output_base64sha256
  dynamo_stream_arn      = module.dynamoQuejas.stream_arn
}

module "cognito" {
  source                  = "./modules/cognito"
  user_pool_name          = "user-pool-plataforma-vecinos"
  verification_email_subject = "Verifica tu cuenta en Sistema Quejas Vecinos"
  verification_email_message = "Gracias por registrarte. Para verificar tu cuenta, usa este código: {####}."
  user_pool_client_name   = "cliente-user-pool-plataforma"
  callback_urls           = ["${module.api_gateway.api_url}/redirectBucket"]
  logout_urls             = ["${module.api_gateway.api_url}/redirectBucket"]
  cognito_domain          = var.nombre_cognito
  api_gateway_rest_api_id = module.api_gateway.api_id
  region                  = "us-east-1"  # o la región que necesites
  account_id              = data.aws_caller_identity.current.account_id
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
  function_name = "getDenunciaTerraform"
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
  function_name = "postDenunciaTerraform"
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
  api_name                   = "quejasVecinosTerraform2"
  api_description            = "API de Terraform para quejas de vecinos"
  cognito_authorizer_id      = module.cognito.authorizer_id
  get_lambda_uri             = aws_lambda_function.get_denuncia.invoke_arn
  post_lambda_uri            = aws_lambda_function.post_denuncia.invoke_arn
  redirect_lambda_uri        = aws_lambda_function.redirect.invoke_arn
  get_lambda_function_name   = aws_lambda_function.get_denuncia.function_name
  post_lambda_function_name  = aws_lambda_function.post_denuncia.function_name
  redirect_lambda_function_name = aws_lambda_function.redirect.function_name
  stage_name                 = "prod"
}

module "s3_static_site" {
  source           = "./modules/static_site"  # Ruta hacia el módulo
  nombre_bucket    = var.nombre_bucket   # Variable que ya debería estar definida
  bucket_name_tag  = "TP Cloud Estatico" # Puedes cambiar estos valores si necesitas
  environment_tag  = "Prod"
}

# Subir el archivo index.html
resource "aws_s3_object" "index_html" {
  bucket = module.s3_static_site.bucket_name
  key    = "index.html"
  source = "web/index.html"  # Ruta local del archivo
  content_type = "text/html"
}