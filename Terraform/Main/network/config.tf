terraform {
  backend "s3" {
    bucket = "docker-assignment-Sudeep-s3"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}