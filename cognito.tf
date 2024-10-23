resource "aws_cognito_user_pool" "user_pool" {
  name = "user-pool-plataforma-vecinos"
  username_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  auto_verified_attributes = ["email"]
  
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Verifica tu cuenta en Sistema Quejas Vecinos"
    email_message        = "Gracias por registrarte. Para verificar tu cuenta, usa este código: {####}."
  }
}
resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name         = "cliente-user-pool-plataforma"

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = ["${aws_api_gateway_deployment.deployment.invoke_url}/redirectBucket"]
  logout_urls                          = ["${aws_api_gateway_deployment.deployment.invoke_url}/redirectBucket"]

  supported_identity_providers = ["COGNITO"]

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain      = var.nombre_cognito # Este debe ser único a nivel global.
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

# Creación del authorizer para Cognito
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.quejas_api.id
  authorizer_uri = "arn:aws:cognito-idp:us-east-1:${data.aws_caller_identity.current.account_id}:userpool/${aws_cognito_user_pool.user_pool.id}"
  type          = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns = [aws_cognito_user_pool.user_pool.arn]
}