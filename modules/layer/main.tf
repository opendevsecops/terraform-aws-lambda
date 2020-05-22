locals {
  name = var.name

  runtimes = var.runtimes

  source_dir = var.source_dir
  output_dir = var.output_dir

  builder_command   = var.builder_command
  builder_container = var.builder_container

  tags = var.tags
}

module "lambda_layer_archive_builder" {
  source  = "opendevsecops/archive-builder/local"
  version = "1.0.0"

  name   = local.name
  prefix = "lambda-layer-"

  source_dir = local.source_dir
  output_dir = local.output_dir

  command   = local.builder_command
  container = local.builder_container

  tags = local.tags
}

resource "aws_lambda_layer_version" "main" {
  filename         = module.lambda_layer_archive_builder.output_file
  source_code_hash = module.lambda_layer_archive_builder.output_file_hash

  layer_name          = local.name
  compatible_runtimes = local.runtimes

  depends_on = [
    module.lambda_layer_archive_builder
  ]
}
