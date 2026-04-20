output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.web_sg.sg_id
}

output "web_server_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.public_ip
}

output "api_server_ip" {
  description = "Public IP of the API server"
  value       = module.api_server.public_ip
}

output "web_server_id" {
  description = "Instance ID of the web server"
  value       = module.web_server.instance_id
}

output "api_server_id" {
  description = "Instance ID of the API server"
  value       = module.api_server.instance_id
}
