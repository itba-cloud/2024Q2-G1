# Crear API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["EDGE"]
  }
}

# Crear recurso /quejasVecinos
resource "aws_api_gateway_resource" "quejas_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "quejasVecinos"
}

# Método GET vinculado a Lambda getDenuncia
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.quejas_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.cognito_authorizer_id
}

resource "aws_api_gateway_method_response" "get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.quejas_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "get_integration" {
  http_method             = aws_api_gateway_method.get_method.http_method
  resource_id             = aws_api_gateway_resource.quejas_resource.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.get_lambda_uri
}

resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.quejas_resource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.get_method_response.status_code
  depends_on  = [aws_api_gateway_integration.get_integration]
}

# Método POST vinculado a Lambda postDenuncia
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.quejas_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.cognito_authorizer_id
}

resource "aws_api_gateway_method_response" "post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.quejas_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "post_integration" {
  http_method             = aws_api_gateway_method.post_method.http_method
  resource_id             = aws_api_gateway_resource.quejas_resource.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.post_lambda_uri
}

resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.quejas_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = aws_api_gateway_method_response.post_method_response.status_code
  depends_on  = [aws_api_gateway_integration.post_integration]
}

# Habilitar CORS (El módulo crea un método OPTIONS y cambia modificaciones)
module "cors" {
  source  = "mewa/apigateway-cors/aws"
  version = "2.0.1"
  api      = aws_api_gateway_rest_api.api.id
  resource = aws_api_gateway_resource.quejas_resource.id
  methods = ["GET", "POST"]
}

# Crear recurso /redirectBucket
resource "aws_api_gateway_resource" "redirect_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "redirectBucket"
}

# Método GET vinculado a Lambda redirect
resource "aws_api_gateway_method" "redirect_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.redirect_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "redirect_integration" {
  http_method             = aws_api_gateway_method.redirect_method.http_method
  resource_id             = aws_api_gateway_resource.redirect_resource.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.redirect_lambda_uri
}

# Despliegue de la API
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name

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

# Permisos de invocación Lambda para el método GET
resource "aws_lambda_permission" "apigw_get_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = var.get_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

# Permisos de invocación Lambda para el método POST
resource "aws_lambda_permission" "apigw_post_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayPost"
  action        = "lambda:InvokeFunction"
  function_name = var.post_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

# Permisos de invocación Lambda para el método redirect
resource "aws_lambda_permission" "apigw_redirect_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayRedirect"
  action        = "lambda:InvokeFunction"
  function_name = var.redirect_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}
