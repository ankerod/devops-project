output "public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP adress of the main EC2 instance."
}

output "ssh_command" {
  description = "Command for SSH connect to EC2 instance."
  value       = "ssh -i ~/.ssh/${var.ssh_key_name} ec2-user@${aws_instance.web_server.public_ip}"
  sensitive   = false
}