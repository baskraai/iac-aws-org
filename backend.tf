terraform {
  backend "remote" {
    organization = "familiekraai"

    workspaces {
      name = "iac-aws-org"
    }
  }
}
