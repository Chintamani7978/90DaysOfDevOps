variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress_ports" {
  description = "List of ingress ports to allow"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}
