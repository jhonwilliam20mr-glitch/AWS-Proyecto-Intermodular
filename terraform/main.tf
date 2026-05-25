provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "bucket-proyecto-1"
    key    = "demo/nextcloud.tfstate"
    region = "us-east-1"
  }
}
