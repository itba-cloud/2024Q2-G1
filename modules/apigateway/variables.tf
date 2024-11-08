variable "api_name" {
  description = "Nombre del API Gateway"
  type        = string
}

variable "api_description" {
  description = "Descripción del API Gateway"
  type        = string
}

variable "cognito_authorizer_id" {
  description = "ID del autorizador de Cognito"
  type        = string
}

variable "get_lambda_uri" {
  description = "URI de la función Lambda para el método GET"
  type        = string
}

variable "getReservas_lambda_uri" {
  description = "URI de la función Lambda para el método GET"
  type        = string
}

variable "post_lambda_uri" {
  description = "URI de la función Lambda para el método POST"
  type        = string
}

variable "postReservas_lambda_uri" {
  description = "URI de la función Lambda para el método POST"
  type        = string
}


variable "redirect_lambda_uri" {
  description = "URI de la función Lambda para el método redirect"
  type        = string
}

variable "stage_name" {
  description = "Nombre del stage de despliegue"
  type        = string
}

variable "get_lambda_function_name" {
  description = "Nombre de la función Lambda para el método GET"
  type        = string
}

variable "getReservas_lambda_function_name" {
  description = "Nombre de la función Lambda para el método GET"
  type        = string
}

variable "post_lambda_function_name" {
  description = "Nombre de la función Lambda para el método POST"
  type        = string
}

variable "postReservas_lambda_function_name" {
  description = "Nombre de la función Lambda para el método POST"
  type        = string
}

variable "redirect_lambda_function_name" {
  description = "Nombre de la función Lambda para el método redirect"
  type        = string
}
