terraform {
  backend "s3" {
    bucket = "tetris-terraform-bucket"
    key = "eks-terraform.tfstate"
    region = "us-east-1"
  }
}

