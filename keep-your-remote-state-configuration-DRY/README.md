## Keep your remote state configuration DRY

```
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "${get_aws_account_id()}-lock-table"
  }
}
EOF
}
```