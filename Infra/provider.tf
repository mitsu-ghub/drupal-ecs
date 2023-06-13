# Define AWS provider
provider "aws" {
  region = "us-east-2"  
}


terraform {
  backend "s3" {
    bucket                  = "terraform-s3-state-mitsu"
    key                     = "my-terraform-project"
    region                  = "us-east-2"
  }
}
