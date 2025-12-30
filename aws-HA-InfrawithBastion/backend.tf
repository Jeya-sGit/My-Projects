terraform {
  backend "s3" {
    bucket         = "jeya-terraform-state-storage" 
    key            = "vpc-project/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock" 
  }
}