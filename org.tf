resource "aws_organizations_organization" "famkraai" {
  aws_service_access_principals = [
    "sso.amazonaws.com",
  ]
  enabled_policy_types          = [
    "SERVICE_CONTROL_POLICY",
  ]
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.famkraai.roots[0].id
  tags = {
    managed = "Terraform"
    repo = yamldecode(data.aws_s3_object.config.body).repo
  }
}

resource "aws_organizations_organizational_unit" "services" {
  name      = "Services"
  parent_id = aws_organizations_organization.famkraai.roots[0].id
  tags = {
    managed = "Terraform"
    repo = yamldecode(data.aws_s3_object.config.body).repo
  }
}

resource "aws_organizations_account" "root" {
  name  = "Familie Kraai Root"
  email = yamldecode(data.aws_s3_object.config.body).aws_accs.root_email
  parent_id = aws_organizations_organizational_unit.security.id
  tags = {
    managed = "Terraform"
    repo = yamldecode(data.aws_s3_object.config.body).repo
  }
}
