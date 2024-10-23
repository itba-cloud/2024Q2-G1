module "vpc_interno" {
  source  = "./modules_vpc_interno"
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
resource "aws_dynamodb_table" "dynamoQuejas" {
  name           = "quejasVecinosTerra"
  billing_mode   = "PROVISIONED"

  # Claves de partición y orden
  hash_key       = "pk_urg"
  range_key      = "sk_tipo_id"

  # Definición de los atributos
  attribute {
    name = "pk_urg"
    type = "S"
  }

  attribute {
    name = "sk_tipo_id"
    type = "S"
  }

  # Capacidad provisionada
  read_capacity  = 1
  write_capacity = 1

  # Recuperación en un punto en el tiempo (Point-in-time recovery)
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "DynamoQuejasVecinos"
  }
}

#Agregar un registro a la DynamoDB
resource "aws_dynamodb_table_item" "queja_jardineria" {
  table_name = aws_dynamodb_table.dynamoQuejas.name
  hash_key   = "pk_urg"
  range_key  = "sk_tipo_id"

  item = <<ITEM
  {
    "pk_urg": {"S": "URG#ALTA"},
    "sk_tipo_id": {"S": "TIPO#JARDINERÍA#9cf10a83-6374-42b6-be67-8d6c252f41e4"},
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
}

# Crear API Gateway
resource "aws_api_gateway_rest_api" "quejas_api" {
  name        = "quejasVecinosTerraform2"
  description = "API de Terraform para quejas de vecinos"
  
  endpoint_configuration {
    types = ["EDGE"]  # Usar tipo Edge-optimized según la imagen
  }
}

# Crear recurso /quejasVecinos
resource "aws_api_gateway_resource" "quejas_resource" {
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  parent_id   = aws_api_gateway_rest_api.quejas_api.root_resource_id
  path_part   = "quejasVecinos"
}

# Método GET vinculado a Lambda getDenuncia
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.quejas_api.id
  resource_id   = aws_api_gateway_resource.quejas_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method_response" "get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  resource_id = aws_api_gateway_resource.quejas_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "get_integration" {
  http_method = aws_api_gateway_method.get_method.http_method
  resource_id = aws_api_gateway_resource.quejas_resource.id
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri = aws_lambda_function.get_denuncia.invoke_arn
}

resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  resource_id = aws_api_gateway_resource.quejas_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.get_method_response.status_code
  depends_on = [
    aws_api_gateway_integration.get_integration
  ]
}

# Método POST vinculado a Lambda postDenuncia
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.quejas_api.id
  resource_id   = aws_api_gateway_resource.quejas_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method_response" "post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  resource_id = aws_api_gateway_resource.quejas_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "post_integration" {
  http_method = aws_api_gateway_method.post_method.http_method
  resource_id = aws_api_gateway_resource.quejas_resource.id
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri = aws_lambda_function.post_denuncia.invoke_arn
}

resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  resource_id = aws_api_gateway_resource.quejas_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = aws_api_gateway_method_response.post_method_response.status_code
  depends_on = [
    aws_api_gateway_integration.post_integration
  ]
}

# Habilitar CORS (El módulo crea un método OPTIONS y cambia modificaciones)
module "cors" {
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"
  api      = aws_api_gateway_rest_api.quejas_api.id
  resource = aws_api_gateway_resource.quejas_resource.id
  methods = ["GET", "POST"]
}

# Crear recurso /redirectBucket
resource "aws_api_gateway_resource" "redirect_resource" {
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  parent_id   = aws_api_gateway_rest_api.quejas_api.root_resource_id
  path_part   = "redirectBucket"
}

#Método GET vinculado al redirect
resource "aws_api_gateway_method" "redirect_method" {
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  resource_id = aws_api_gateway_resource.redirect_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "redirect_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  resource_id = aws_api_gateway_resource.redirect_resource.id
  http_method             = aws_api_gateway_method.redirect_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.redirect.invoke_arn
}

# Deploy de la API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  
  rest_api_id = aws_api_gateway_rest_api.quejas_api.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.quejas_resource.id,
      aws_api_gateway_resource.redirect_resource.id,
      aws_api_gateway_method.redirect_method.id,
      aws_api_gateway_method.get_method.id,
      aws_api_gateway_integration.get_integration.id,
      aws_api_gateway_method.post_method.id,
      aws_api_gateway_integration.post_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.get_integration,
    aws_api_gateway_integration.post_integration,
  ]
}

resource "aws_lambda_permission" "apigw_get_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_denuncia.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.quejas_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "apigw_post_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_denuncia.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.quejas_api.execution_arn}/*/*/*"
}


resource "aws_lambda_permission" "apigw_redirect_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.quejas_api.execution_arn}/*/*/*"
}

# BUCKET Frontend
# Crear el bucket S3 para el sitio web estático
resource "aws_s3_bucket" "static_site" {
  bucket = var.nombre_bucket  # El nombre del bucket debe ser único a nivel global

  tags = {
    Name        = "TP Cloud Estatico"
    Environment = "Prod"
  }
}

# Configuración del sitio web estático
resource "aws_s3_bucket_website_configuration" "static_site_config" {
  bucket = aws_s3_bucket.static_site.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# Hacer públicos los objetos del bucket 
resource "aws_s3_bucket_public_access_block" "static_site_block" {
  bucket = aws_s3_bucket.static_site.id
  block_public_acls   = true
  block_public_policy = false
}

# Política para permitir acceso público al bucket
resource "aws_s3_bucket_policy" "static_site_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

# Subir el archivo index.html
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static_site.bucket
  key    = "index.html"
  source = "web/index.html"  # Ruta local del archivo
  content_type = "text/html"
}