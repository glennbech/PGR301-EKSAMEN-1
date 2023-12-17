terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
 backend "s3" {
    bucket = "pgr301-2021-terraform-state"
    key    = "candidate-2039/s3-bucket-sensur.state"
    region = "eu-north-1"
 }
}

provider "aws"{
  region="eu-west-1"
}