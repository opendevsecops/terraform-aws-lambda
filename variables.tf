variable "name" {
  description = "A unique name for your Lambda Function."
  type        = string
}

variable "role_name" {
  description = "A unique name for your Lambda Function Role."
  type        = string
}

variable "runtime" {
  description = "The runtimes for your Lambda Function."
  type        = string
  default     = "nodejs10.x"
}

variable "handler" {
  description = "The handler for your Lambda Function."
  type        = string
  default     = "index.handler"
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in lambda function log group."
  type        = number
  default     = 90
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 3
}

variable "environment" {
  description = "A map that defines environment variables for the Lambda function."
  type        = map
  default     = { dummy = "_" }
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function."
  type        = list(string)
  default     = []
}
variable "schedule" {
  description = "A cloud watch execution schedule for the Lambda function."
  type        = list(object({ name = string, schedule_expression = string, input = string }))
  default     = []
}

variable "apigws" {
  description = "The AWS API GW ARNs which executes this Lambda function."
  type        = list(string)
  default     = []
}

variable "source_dir" {
  description = "The function folder to be archived."
  type        = string
}

variable "output_dir" {
  description = "The function folder for building purposes."
  type        = string
}

variable "builder_command" {
  description = "Builder command."
  type        = string
  default     = ""
}

variable "builder_container" {
  description = "Builder container."
  type        = string
  default     = ""
}
