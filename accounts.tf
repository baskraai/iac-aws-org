resource "aws_organizations_account" "accounts" {
  name  = "Accounts"
  email = yamldecode(data.aws_s3_object.config.body).aws_accs.account_email
  parent_id = aws_organizations_organizational_unit.security.id
  tags = {
    managed = "Terraform"
    repo = "iac-aws-org"
  }
}

resource "aws_organizations_account" "service_accounts" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name  = each.value.name
  email = each.value.email
  parent_id = aws_organizations_organizational_unit.services.id
  tags = {
    managed = "Terraform"
    repo = yamldecode(data.aws_s3_object.config.body).repo
  }
}
