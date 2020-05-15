output "name" {
  value = var.name
}

output "role_name" {
  value = var.role_name
}

output "arn" {
  value = aws_lambda_function.main.arn
}

output "role_arn" {
  value = aws_iam_role.main.arn
}

