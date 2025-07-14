terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-12387612-south"
    key            = "home/ubuntu/terraform/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }
}

