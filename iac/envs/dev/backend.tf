# Points this environment's state at the bucket and lock table created by
# iac/bootstrap. These values cannot be variables (Terraform must know the
# backend before it knows what a variable even is), so they are copied here
# as literal values from the bootstrap module's outputs.
terraform {
  backend "s3" {
    bucket       = "bank-of-anthos-tfstate-826113468369"
    key          = "envs/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
