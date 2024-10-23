# Output para obtener el invoke url del API Gateway
output "invoke_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

# Output para obtener la URL del sitio web estático
output "website_url" {
  value       = aws_s3_bucket_website_configuration.static_site_config.website_endpoint
  description = "URL del sitio web estático"
}

#Output para obtener la URL del Hosted UI de Cognito
output "cognito_hosted_ui_url" {
  value = "https://${aws_cognito_user_pool_domain.user_pool_domain.domain}.auth.us-east-1.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.user_pool_client.id}&response_type=code&scope=openid&redirect_uri=${aws_api_gateway_deployment.deployment.invoke_url}/redirectBucket"
  description = "Hosted UI URL for Cognito"
}

#Output id user pool
output "user_pool_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
  description = "user pool id"
}

output "cognito_domain" {
    value = aws_cognito_user_pool_domain.user_pool_domain.domain
}