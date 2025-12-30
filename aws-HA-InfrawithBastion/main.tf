resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "vpc_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${aws_key_pair.vpc_key.key_name}.pem"
  content         = tls_private_key.rsa.private_key_pem
  file_permission = "0400"
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_name}-bastion-sg"
  description = "Bastion security group"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Best Practice: Replace with  Specific/Our System IP Address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  } 
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.vpc_key.key_name
  associate_public_ip_address = true 

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

module "vpc" {
  source = "git::https://github.com/Jeya-sGit/Terraform.git//aws-vpc-asg-infra-modular/modules/vpc?ref=main"
  vpc_cidr     = "10.0.0.0/16"
}

module "compute" {
  source = "git::https://github.com/Jeya-sGit/Terraform.git//aws-vpc-asg-infra-modular/modules/compute?ref=main"

  project_name = var.project_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  
  bastion_sg_id      = aws_security_group.bastion_sg.id

  ami_id        = var.ami_id
  instance_type = var.instance_type
  ssh_key_name  = aws_key_pair.vpc_key.key_name
}

data "aws_instances" "asg_instances" {
  instance_state_names = ["running"]
  
  filter {
    name   = "tag:Name"
    values = ["terraform-created-EC2-Instance"] 
  }

  depends_on = [module.compute]
}

