# depends_on workaround

variable "module_depends_on" {
  description = "Helper variable to simulate depends_on for terraform modules"
  type        = list
  default     = [""]
}

output "module_depends_on" {
  value = "${var.module_depends_on}"
}

resource "null_resource" "module_depends_on" {
  triggers = {
    value = length(var.module_depends_on)
  }
}
