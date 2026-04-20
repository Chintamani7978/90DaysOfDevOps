output "sg_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}

output "sg_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.this.arn
}

output "sg_name" {
  description = "Name of the security group"
  value       = aws_security_group.this.name
}
