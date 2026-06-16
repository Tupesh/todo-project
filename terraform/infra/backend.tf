terraform {
  backend "s3" {
    bucket       = "tupesh-terraform-state-bucket"
    key          = "dev/devops-platform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}