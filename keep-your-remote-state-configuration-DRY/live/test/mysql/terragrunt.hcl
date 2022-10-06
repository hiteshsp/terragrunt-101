locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

terraform {
  # Deploy version v0.0.3 in stage
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git"
  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var-file=${get_terragrunt_dir()}/${get_aws_account_id()}.tfvars"
    ]
  }
  extra_arguments "disable_input" {
    commands = get_terraform_commands_that_need_input()
    arguments = ["-input=false"]
  }
  extra_arguments "parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=5"]
  }
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  instance_class = "db.m6i.large"
}