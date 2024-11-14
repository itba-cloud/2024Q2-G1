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
