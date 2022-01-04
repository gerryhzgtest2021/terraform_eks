terraform {
  backend "s3" {
    bucket = "gerryhzgtest2021-terraform-state"
    key    = "state/terraform_kubernetes"
    region = "us-east-1"
  }
}
