provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "aws-proyecto-intermodular-tfstate"
    key    = "demo/nextcloud.tfstate"
    region = "us-east-1"
  }
}
