variable "project_name" {
    description = "The name of the project"
    type        = string
    default = "AWS-HA-App"
}

variable "instance_type" {
  description = "The type of EC2 instance to use in the Auto Scaling Group (e.g., t2.micro)."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) to use for the EC2 instances."
  type        = string
  default     = "ami-0d176f79571d18a8f"
}
