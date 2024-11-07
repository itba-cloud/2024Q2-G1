resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  hash_key       = var.hash_key
  range_key      = var.range_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  attribute {
    name = var.range_key
    type = "S"
  }

  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  point_in_time_recovery {
    enabled = var.pitr_enabled
  }

  tags = var.tags
}

#Agregar un registro a la DynamoDB
resource "aws_dynamodb_table_item" "queja_jardineria" {
  table_name = aws_dynamodb_table.this.name
  hash_key   = "pk_urg"
  range_key  = "sk_tipo_id"

  item = <<ITEM
  {
    "pk_urg": {"S": "URG#ALTA"},
    "sk_tipo_id": {"S": "TIPO#JARDINERÍA#9cf10a83-6374-42b6-be67-asdasdd"},
    "detalle": {"S": "iaisjdab"},
    "estado": {"S": "PENDIENTE"},
    "fecha": {"S": "2024-10-10"},
    "idDenuncia": {"S": "9cf10a83-6374-42b6-be67-8d6c252f41e4"},
    "nombre_propietario": {"S": "Fede Capo"},
    "tipo": {"S": "JARDINERÍA"},
    "titulo": {"S": "laksjdlkj"},
    "urgencia": {"S": "ALTA"}
  }
  ITEM
}