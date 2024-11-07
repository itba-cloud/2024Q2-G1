variable "user_pool_name" {
  description = "Nombre del pool de usuarios de Cognito"
  type        = string
}

variable "verification_email_subject" {
  description = "Asunto del correo de verificación"
  type        = string
}

variable "verification_email_message" {
  description = "Mensaje del correo de verificación"
  type        = string
}

variable "user_pool_client_name" {
  description = "Nombre del cliente del pool de usuarios"
  type        = string
}

variable "callback_urls" {
  description = "Lista de URLs de callback permitidas"
  type        = list(string)
}

variable "logout_urls" {
  description = "Lista de URLs de logout permitidas"
  type        = list(string)
}

variable "cognito_domain" {
  description = "Dominio de Cognito único"
  type        = string
}

variable "api_gateway_rest_api_id" {
  description = "ID de la API Gateway para el authorizer de Cognito"
  type        = string
}

variable "region" {
  description = "Región de AWS"
  type        = string
}

variable "account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}
