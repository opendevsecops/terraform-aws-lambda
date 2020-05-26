[![Follow on Twitter](https://img.shields.io/twitter/follow/opendevsecops.svg?logo=twitter)](https://twitter.com/opendevsecops)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d3cdea1d93de4f9791f92aec8306e6f8)](https://www.codacy.com/app/OpenDevSecOps/terraform-aws-lambda?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=opendevsecops/terraform-aws-lambda&amp;utm_campaign=Badge_Grade)

# AWS Lambda Terraform Module

A helper module to deploy lambda functions in a quick and consistent fashion. The module will take care of a lot of boilerplate code such as creating roles, setting up the correct permissions for CloudWatch, configure log retention windows, setup CloudWatch triggers, correct assign AWS API Gateway permissions and more.

This module is used extensively throughout other OpenDevSecOps projects as well as [secapps.com](secapps.com).

## Getting Started

The module is automatically published to the Terraform Module Registry. More information about the available inputs, outputs, dependencies, and instructions on how to use the module can be found at the official page [here](https://registry.terraform.io/modules/opendevsecops/lambda).

The following example can be used as starting point:

```terraform
module "acme_lambda" {
  source  = "opendevsecops/lambda/aws"
  version = "2.0.0"

  runtime = "nodejs10.x"

  source_dir  = "../src/"
  output_dir = "../build/"

  name      = "acme_agent"
  role_name = "acme_agent_role"

  log_retention_in_days = 90
  timeout = 300

  environment {
    ACME_KEY_ID = data.aws_secretsmanager_secret.acme.id
  }

  schedule = [
    {
      name                = "RunDaily"
      schedule_expression = "rate(1 day)"
      input = <<EOF
{
  "op": "runSchedule",
  "params": {
    "schedule": "daily"
  }
}
EOF
    }
  ]

  tags = local.tags

  module_depends_on = [
      aws_secretsmanager_secret.acme
  ]
}
```

You can setup additional permissions using a custom role policy like this:

```terraform
resource "aws_iam_role_policy" "acme_agent_role_policy" {
  name = "policy"
  role = module.acme_lambda.role_name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "${data.aws_secretsmanager_secret.acme.arn}"
    }
  ]
}
EOF
}
```

Refer to the module registry [page](https://registry.terraform.io/modules/opendevsecops/lambda) for additional information on optional inputs and configuration.
