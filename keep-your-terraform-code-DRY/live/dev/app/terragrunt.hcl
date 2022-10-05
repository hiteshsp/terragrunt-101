terraform {
  # Deploy version v0.0.3 in stage
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}

inputs = {
  instance_type  = "t2.micro"
}
