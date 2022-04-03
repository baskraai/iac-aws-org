resource "aws_organizations_account" "accounts" {
  name  = "Accounts"
  email = yamldecode(data.aws_s3_object.config.body).aws_accs.account_email
  parent_id = aws_organizations_organizational_unit.security.id
  provider = aws.ssoandorg
  tags = {
    managed = "Terraform"
    repo = "iac-aws-org"
  }
}

resource "aws_organizations_account" "service_accounts" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name  = title(replace(each.key,"_"," "))
  email = each.value.email
  parent_id = aws_organizations_organizational_unit.services.id
  provider = aws.ssoandorg
  tags = {
    managed = "Terraform"
    repo = yamldecode(data.aws_s3_object.config.body).repo
  }
}

data "aws_ssoadmin_instances" "sso" {
  provider = aws.ssoandorg
}

resource "aws_ssoadmin_permission_set" "services_full_admin" {
  name             = "ServicesFullAdmin"
  description      = "Full admin in the services-accounts"
  instance_arn     = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  session_duration = "PT12H"
  provider = aws.ssoandorg
}

resource "aws_ssoadmin_managed_policy_attachment" "services" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.services_full_admin.arn
  provider = aws.ssoandorg
}

data "aws_identitystore_group" "services_admin" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
  filter {
    attribute_path = "DisplayName"
    attribute_value = var.aws_sso_admin_group
  }
  provider = aws.ssoandorg
}

resource "aws_ssoadmin_account_assignment" "services_group" {
  for_each = aws_organizations_account.service_accounts
  instance_arn       = resource.aws_ssoadmin_permission_set.services_full_admin.instance_arn
  permission_set_arn = resource.aws_ssoadmin_permission_set.services_full_admin.arn

  principal_id   = data.aws_identitystore_group.services_admin.group_id
  principal_type = "GROUP"

  target_id   = each.value.id
  target_type = "AWS_ACCOUNT"
  provider = aws.ssoandorg
}

output "org_accounts" {
  value = {
    for k, v in aws_organizations_account.service_accounts : k => v.id
  }
}

resource "aws_iam_user" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name = "sa_iac-aws-${each.key}"
  path = "/"
  provider = aws.iam
  tags = {
    managed = "Terraform"
    repo = yamldecode(data.aws_s3_object.config.body).repo
  }
}

resource "aws_iam_access_key" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  user = aws_iam_user.services[each.key].name
  provider = aws.iam
}

resource "aws_iam_user_policy" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name = "sa_iac-aws-${each.key}"
  user = aws_iam_user.services[each.key].name
  provider = aws.iam
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PipelineAdminSA",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::${resource.aws_organizations_account.service_accounts[each.key].id}:role/PipelineAdmin"
        }
    ]
}
EOF
}
