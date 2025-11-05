terraform {
  backend "s3" {
    bucket = "devops-deploy-project"   # your bucket name
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
