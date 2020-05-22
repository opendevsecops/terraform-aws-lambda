[![Follow on Twitter](https://img.shields.io/twitter/follow/opendevsecops.svg?logo=twitter)](https://twitter.com/opendevsecops)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d3cdea1d93de4f9791f92aec8306e6f8)](https://www.codacy.com/app/OpenDevSecOps/terraform-aws-lambda?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=opendevsecops/terraform-aws-lambda&amp;utm_campaign=Badge_Grade)

# AWS Lambda/Layer Terraform Module

A helper module to deploy lambda layers in a quick and consistent fashion.

This module is used extensively throughout other OpenDevSecOps projects as well as [secapps.com](secapps.com).

## Getting Started

The module is automatically published to the Terraform Module Registry. More information about the available inputs, outputs, dependencies, and instructions on how to use the module can be found at the official page [here](https://registry.terraform.io/modules/opendevsecops/lambda).

The following example can be used as starting point:

```terraform
module "acme_layer" {
  source  = "opendevsecops/lambda/aws//modules/layer"
  version = "2.0.0"

  source_dir  = "../src/acme-layer"
  output_dir = "../build/"

  name = "acme"

  tags = local.tags
}
```

Use the layer in the following way:

```terraform
module "acme_lambda" {
  source  = "opendevsecops/lambda/aws"
  version = "2.0.0"

  runtime = "nodejs10.x"

  source_dir  = "../src/acme-function"
  output_dir = "../build/"

  name      = "acme_agent"
  role_name = "acme_agent_role"
  
  layers = [module.acme_layer.arn]

  tags = local.tags
}
```

Refer to the module registry [page](https://registry.terraform.io/modules/opendevsecops/lambda) for additional information on optional inputs and configuration.
