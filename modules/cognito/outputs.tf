output "user_pool_id" {
  description = "ID del pool de usuarios de Cognito"
  value       = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  description = "ID del cliente del pool de usuarios"
  value       = aws_cognito_user_pool_client.user_pool_client.id
}

output "user_pool_domain" {
  description = "Dominio del pool de usuarios de Cognito"
  value       = aws_cognito_user_pool_domain.user_pool_domain.domain
}

output "authorizer_id" {
  description = "ID del authorizer de API Gateway"
  value       = aws_api_gateway_authorizer.cognito_authorizer.id
}