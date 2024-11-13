# Output para obtener el invoke url del API Gateway
output "invoke_url" {
  value = module.api_gateway.api_url
}

# Output para obtener la URL del sitio web estático
output "website_url_formulario" {
  value       = module.s3_static_site_formulario.bucket_website_endpoint
  description = "URL del sitio web estático"
}

# Output para obtener la URL del sitio web estático
output "website_url" {
  value       = module.s3_static_site.bucket_website_endpoint
  description = "URL del sitio web estático"
}

#Output para obtener la URL del Hosted UI de Cognito
output "cognito_hosted_ui_url" {
  value = "https://${module.cognito.user_pool_domain}.auth.us-east-1.amazoncognito.com/login?client_id=${module.cognito.user_pool_client_id}&response_type=code&scope=openid&redirect_uri=${module.api_gateway.api_url}/redirectBucket"
  description = "Hosted UI URL for Cognito"
}

#Output id user pool
output "user_pool_id" {
  value = module.cognito.user_pool_client_id
  description = "user pool id"
}

output "cognito_domain" {
    value = module.cognito.user_pool_domain
}