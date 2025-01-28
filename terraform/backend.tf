
terraform {
  backend "s3" {
    bucket         = "flask-terraform-backend"
    key            = "flask/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "flask-terraform-lock"
    encrypt        = true
  }
}