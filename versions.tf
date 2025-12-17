terraform {
  required_version = ">= 1.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  profile = "eeswar"
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"


}

# terraform {
#     backend "s3" {
#     bucket = "eeswar-terraform-state"
#     key = "terraform.tfstate"
#     region = "us-east-1"
#     use_lockfile = true
#     encrypt = true
#     dynamodb_table = "eeswar-terraform-lock"
#     profile = "eeswar"
#   }
# }













