variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "nombre_cognito" {
  description = "nombre del cognito user pool"
  type = string
}

variable "bucket_imagenes" {
  description = "nombre del bucket de imagenes"
  type = string
}

variable "nombre_bucket" {
  description = "nombre del bucket"
  type = string
}

variable "nombre_bucket_formulario" {
  description = "nombre del bucket"
  type = string
}

variable "mail_admin" {
  description = "Mail del admin que recibe las alertas"
  type = string
}

#A las subnets les paso la cantidad de AZs que quiero
variable "cant_AZ" {
  description = "The number of availability zones"
  type        = number
}