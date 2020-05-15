data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

locals {
  name      = var.name
  role_name = var.role_name

  runtime = var.runtime
  handler = var.handler

  log_group             = "/aws/lambda/${var.name}"
  log_retention_in_days = var.log_retention_in_days

  memory_size = var.memory_size
  timeout     = var.timeout

  source_dir  = var.source_dir
  output_path = var.output_path

  environment = var.environment ? var.environment : { dummy = "_" }

  schedule = var.schedule

  apigw_arn = var.apigw_arn

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "main" {
  name              = local.log_group
  retention_in_days = local.log_retention_in_days

  tags = local.tags
}

resource "aws_iam_role" "main" {
  name = local.role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "main_policy" {
  role = aws_iam_role.main.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group}:*:*",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group}"
      ]
    }
  ]
}
EOF

}

data "archive_file" "main" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = local.output_path
}

resource "aws_lambda_function" "main" {
  function_name    = local.name
  handler          = local.handler
  runtime          = local.runtime
  filename         = local.output_path
  source_code_hash = data.archive_file.main.output_base64sha256
  role             = aws_iam_role.main.arn
  memory_size      = local.memory_size
  timeout          = local.timeout

  environment {
    variables = local.environment
  }

  tags = local.tags
}

resource "aws_cloudwatch_event_rule" "schedule" {
  count               = length(local.schedule)
  name                = local.schedule[count.index].name
  schedule_expression = local.schedule[count.index].schedule_expression

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "schedule" {
  count     = length(local.schedule)
  rule      = local.schedule[count.index].name
  target_id = local.schedule[count.index].name
  arn       = aws_lambda_function.main.arn
  input     = local.schedule[count.index].input
}

resource "aws_lambda_permission" "schedule" {
  count         = length(local.schedule)
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[count.index].arn
}

resource "aws_lambda_permission" "apigw" {
  count         = local.apigw_arn ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = local.apigw_arn
}
