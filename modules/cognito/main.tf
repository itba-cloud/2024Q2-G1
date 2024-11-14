resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name
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
    email_subject        = var.verification_email_subject
    email_message        = var.verification_email_message
  }

  lambda_config {
    post_confirmation = var.lambda_subscribe_sns
  }
} 

resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name         = var.user_pool_client_name

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls

  supported_identity_providers = ["COGNITO"]

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name             = "cognito-authorizer"
  rest_api_id      = var.api_gateway_rest_api_id
  authorizer_uri   = "arn:aws:cognito-idp:${var.region}:${var.account_id}:userpool/${aws_cognito_user_pool.user_pool.id}"
  type             = "COGNITO_USER_POOLS"
  identity_source  = "method.request.header.Authorization"
  provider_arns    = [aws_cognito_user_pool.user_pool.arn]
}
