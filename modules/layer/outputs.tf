output "arn" {
  value = aws_lambda_layer_version.main.arn
}

output "layer_arn" {
  value = aws_lambda_layer_version.main.layer_arn
}

output "created_date" {
  value = aws_lambda_layer_version.main.created_date
}

output "source_code_size" {
  value = aws_lambda_layer_version.main.source_code_size
}

output "version" {
  value = aws_lambda_layer_version.main.version
}
