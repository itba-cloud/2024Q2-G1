output "sns_topic_arn" {
  value = aws_sns_topic.email_topic.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.dynamodb_stream_lambda.arn
}