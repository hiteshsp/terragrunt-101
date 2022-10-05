terraform {
  # Deploy version v0.0.3 in stage
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var-file=${get_terragrunt_dir()}/${get_aws_account_id()}.tfvars"
    ]
  }
}

inputs = {
  instance_type  = "t2.medium"
}
