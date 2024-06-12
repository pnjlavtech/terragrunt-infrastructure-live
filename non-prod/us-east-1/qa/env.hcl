# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  cidr        = "10.230.0.0/16"
  environment = "qa"
}


# vpc_cidr = "10.231.0.0/16"   # stg
# vpc_cidr = "10.232.0.0/16"   # prod
