variable "az" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "value of vpc cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "mallesh"
}

variable "ingress_ports" {
  default = [22, 8080, 80]
}
