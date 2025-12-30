output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "ssh_connect_command" {
  description = "The command to connect to the bastion host"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.bastion.public_ip}"
}

output "alb_dns_endpoint" {
  description = "The URL to access your web application"
  value       = "http://${module.compute.alb_dns_name}"
}

output "private_instance_ips" {
  description = "The private IPs of the instances in the ASG"
  value       = data.aws_instances.asg_instances.private_ips
}

output "jump_commands" {
  description = "Copy-paste these to jump to your private instances"
  value       = [
    for ip in data.aws_instances.asg_instances.private_ips : 
    "ssh -i ${local_file.private_key.filename} -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${ip}"
  ]
}