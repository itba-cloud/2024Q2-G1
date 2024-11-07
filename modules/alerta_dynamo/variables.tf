variable "email_endpoint" {
  description = "El email destinatario de las alertas"
  type        = string
}

variable "lambda_name" {
  description = "Nombre de la función Lambda"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN del rol IAM para la función Lambda"
  type        = string
}

variable "lambda_filename" {
  description = "Ruta al archivo zip de la Lambda"
  type        = string
}

variable "lambda_source_code_hash" {
  description = "Hash del archivo zip de la Lambda"
  type        = string
}

variable "dynamo_stream_arn" {
  description = "ARN del stream de la tabla DynamoDB"
  type        = string
}