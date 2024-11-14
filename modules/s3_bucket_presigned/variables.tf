variable "bucket_name" {
  description = "Nombre único para el bucket"
  type        = string
}

variable "environment" {
  description = "Entorno para etiquetar el bucket"
  type        = string
  default     = "Development"
}
