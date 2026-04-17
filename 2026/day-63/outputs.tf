output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.main.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.main.id
}

# Additional useful outputs
output "instance_ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i /path/to/key.pem ec2-user@${aws_instance.main.public_ip}"
}

output "all_outputs" {
  description = "All infrastructure outputs as a map"
  value = {
    vpc_id              = aws_vpc.main.id
    subnet_id           = aws_subnet.public.id
    instance_id         = aws_instance.main.id
    instance_public_ip  = aws_instance.main.public_ip
    instance_public_dns = aws_instance.main.public_dns
    security_group_id   = aws_security_group.main.id
  }
}
