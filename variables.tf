variable "source_dir" {
  description = "The function folder to be archived"
}

variable "output_path" {
  description = "The output of the archive file"
}

variable "name" {
  description = "A unique name for your Lambda Function"
}

variable "role_name" {
  description = "A unique name for your Lambda Function Role"
}

variable "runtime" {
  description = "The runtimes for your Lambda Function."
  default     = "nodejs10.x"
}

variable "handler" {
  description = "The handler for your Lambda Function."
  default     = "index.handler"
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in lambda function log group"
  default     = 90
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  default     = 128
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds"
  default     = 3
}

variable "environment" {
  description = "A map that defines environment variables for the Lambda function"
  type        = map
}

variable "schedule" {
  description = "A cloud watch execution schedule for the Lambda function"
  type        = list(object({ name = string, schedule_expression = string, input = string }))
}

variable "apigw_arn" {
  description = "The AWS API GW arn which executes this Lambda function"
  type        = string
}
