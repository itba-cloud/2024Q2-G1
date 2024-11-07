variable "table_name" {
  description = "Nombre de la tabla"
  type        = string
}

variable "hash_key" {
  description = "Clave de partición de la tabla"
  type        = string
}

variable "range_key" {
  description = "Clave de orden de la tabla"
  type        = string
}

variable "read_capacity" {
  description = "Capacidad de lectura"
  type        = number
  default     = 1
}

variable "write_capacity" {
  description = "Capacidad de escritura"
  type        = number
  default     = 1
}

variable "stream_enabled" {
  description = "Habilitar el stream"
  type        = bool
  default     = true
}

variable "stream_view_type" {
  description = "Tipo de vista del stream"
  type        = string
  default     = "NEW_IMAGE"
}

variable "pitr_enabled" {
  description = "Habilitar recuperación en un punto en el tiempo"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Etiquetas de la tabla"
  type        = map(string)
  default     = {}
}
