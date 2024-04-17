terraform {
  backend "s3" {
    bucket = "tetris-terraform-bucket"
    key = "jenkins-terraform.tfstate"
    region = "us-east-1"
  }
}

