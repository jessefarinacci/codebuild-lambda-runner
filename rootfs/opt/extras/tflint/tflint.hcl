# https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md

config {
  plugin_dir = "/home/ubuntu/.tflint.d/plugins"
}

plugin "aws" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  version = "0.49.0"
}

plugin "terraform" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  version = "0.15.0"
}
