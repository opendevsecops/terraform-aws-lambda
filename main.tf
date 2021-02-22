#
# LOCALS
#

locals {
  name      = var.name
  role_name = var.role_name

  runtime = var.runtime
  handler = var.handler

  log_group             = "/aws/lambda/${var.name}"
  log_retention_in_days = var.log_retention_in_days

  memory_size = var.memory_size
  timeout     = var.timeout

  environment = var.environment

  layers = var.layers

  schedule = var.schedule

  apigateway_execution_arns = var.apigateway_execution_arns

  subscribed_sns_topic_arns = var.subscribed_sns_topic_arns

  subscribed_sqs_queue_arns = var.subscribed_sqs_queue_arns

  role_policy = var.role_policy

  source_dir = var.source_dir
  output_dir = var.output_dir

  builder_command   = var.builder_command
  builder_container = var.builder_container

  tags = var.tags
}

#
# DATA
#

data "aws_region" "current" {
}

data "aws_caller_identity" "current" {
}

resource "aws_cloudwatch_log_group" "main" {
  name              = local.log_group
  retention_in_days = local.log_retention_in_days

  tags = local.tags
}

#
# FUNCTION ROLE AND POLICY
#

resource "aws_iam_role" "main" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = {
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }
  })
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

resource "aws_iam_role_policy" "supplicant_policy" {
  count = local.role_policy == "" ? 0 : 1

  role = aws_iam_role.main.name

  policy = local.role_policy
}

#
# LAMBDA FUNCTION ARCHIVE
#

module "lambda_function_archive_builder" {
  source  = "opendevsecops/archive-builder/local"
  version = "1.0.0"

  name   = local.name
  prefix = "lambda-function-"

  source_dir = local.source_dir
  output_dir = local.output_dir

  command   = local.builder_command
  container = local.builder_container

  tags = local.tags
}

#
# LAMBDA FUNCTION DEFINITION
#

resource "aws_lambda_function" "main" {
  filename         = module.lambda_function_archive_builder.output_file
  source_code_hash = module.lambda_function_archive_builder.output_file_hash

  function_name = local.name
  handler       = local.handler
  runtime       = local.runtime
  role          = aws_iam_role.main.arn
  memory_size   = local.memory_size
  timeout       = local.timeout
  layers        = local.layers

  environment {
    variables = local.environment
  }

  tags = local.tags

  depends_on = [
    module.lambda_function_archive_builder
  ]
}

#
# CLOUDWATCH SCHEDULE
#

resource "aws_cloudwatch_event_rule" "schedule" {
  count = length(local.schedule)

  name                = local.schedule[count.index].name
  schedule_expression = local.schedule[count.index].schedule_expression

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "schedule" {
  count = length(local.schedule)

  rule      = local.schedule[count.index].name
  target_id = local.schedule[count.index].name
  arn       = aws_lambda_function.main.arn
  input     = local.schedule[count.index].input

  depends_on = [
    aws_cloudwatch_event_rule.schedule
  ]
}

resource "aws_lambda_permission" "schedule" {
  count = length(local.schedule)

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[count.index].arn

  depends_on = [
    aws_cloudwatch_event_target.schedule
  ]
}

#
# APIGW
#

resource "aws_lambda_permission" "apigw" {
  count = length(local.apigateway_execution_arns)

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${local.apigateway_execution_arns[count.index]}/*/*/*"
}

#
# SNS
#

resource "aws_lambda_permission" "sns" {
  count = length(local.subscribed_sns_topic_arns)

  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "sns.amazonaws.com"
  source_arn    = local.subscribed_sns_topic_arns[count.index]
}

resource "aws_sns_topic_subscription" "sns" {
  count = length(local.subscribed_sns_topic_arns)

  topic_arn = local.subscribed_sns_topic_arns[count.index]
  protocol  = "lambda"
  endpoint  = aws_lambda_function.main.arn

  depends_on = [
    aws_lambda_permission.sns
  ]
}

#
# SQS
#

resource "aws_iam_role_policy" "sqs_policy" {
  count = length(local.subscribed_sqs_queue_arns) > 0 ? 1 : 0

  role = aws_iam_role.main.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Resource = local.subscribed_sqs_queue_arns
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ListQueues"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "sqs" {
  count = length(local.subscribed_sqs_queue_arns)

  event_source_arn = local.subscribed_sqs_queue_arns[count.index]
  function_name    = aws_lambda_function.main.arn

  depends_on = [
    aws_iam_role_policy.sqs_policy
  ]
}
