variable "name" {
  description = "A unique name for your Lambda Layer."
  type        = string
}

variable "runtimes" {
  description = "A list of Runtimes this layer is compatible with. Up to 5 runtimes can be specified."
  type        = list
  default     = []
}

variable "source_dir" {
  description = "The layer folder to be archived."
  type        = string
}

variable "output_dir" {
  description = "The layer folder for building purposes."
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
