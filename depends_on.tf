# depends_on workaround

variable "depends_on" {
  description = "Helper variable to simulate depends_on for terraform modules"
  default     = []
}

output "depends_on" {
  value = "${var.depends_on}"
}
