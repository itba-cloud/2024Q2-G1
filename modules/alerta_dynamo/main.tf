resource "aws_sns_topic" "email_topic" {
  name = var.sns_name
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn    = aws_sns_topic.email_topic.arn
  protocol     = "email"
  endpoint     = var.email_endpoint  # Parámetro para el email destinatario

  # Agrega la política de filtro
  filter_policy = jsonencode({
    userName = [var.email_endpoint]  # Reemplaza con el nombre y valor de tu atributo
  })
}


resource "aws_lambda_function" "dynamodb_stream_lambda" {
  function_name = var.lambda_name
  role          = var.lambda_role_arn
  handler       = var.lambda_handler
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128
  filename      = var.lambda_filename
  source_code_hash = var.lambda_source_code_hash

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.email_topic.arn
      OTRO_SNS = var.otro_sns_arn
      ADMIN_MAIL = var.email_endpoint
    }
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_trigger" {
  event_source_arn  = var.dynamo_stream_arn
  function_name     = aws_lambda_function.dynamodb_stream_lambda.arn
  starting_position = "LATEST"
}

resource "aws_lambda_permission" "allow_dynamodb_stream" {
  statement_id  = "AllowExecutionFromDynamoDB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamodb_stream_lambda.function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = var.dynamo_stream_arn
}
