resource "tfe_organization" "famkraai" {
  name = yamldecode(data.aws_s3_object.config.body).tfc.name
  email = yamldecode(data.aws_s3_object.config.body).tfc.email
  collaborator_auth_policy = "two_factor_mandatory"
}

resource "tfe_oauth_client" "github" {
  name             = "famkraai_github"
  organization     = tfe_organization.famkraai.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}

resource "tfe_workspace" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name = "iac-aws-${lower(each.key)}"
  organization = tfe_organization.famkraai.name
  vcs_repo {
    identifier         = "${yamldecode(data.aws_s3_object.config.body).github.owner}/${github_repository.services[each.key].name}"
    ingress_submodules = false
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
  
}

resource "tfe_variable" "aws_key" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  key          = "aws_key"
  sensitive    = true
  value        = resource.aws_iam_access_key.services[each.key].id
  category     = "terraform"
  workspace_id = tfe_workspace.services[each.key].id
}

resource "tfe_variable" "aws_secret" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  key          = "aws_secret"
  sensitive    = true
  value        = resource.aws_iam_access_key.services[each.key].secret
  category     = "terraform"
  workspace_id = tfe_workspace.services[each.key].id
}

resource "tfe_variable" "aws_role" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  key          = "aws_role"
  value        = "arn:aws:iam::${resource.aws_organizations_account.service_accounts[each.key].id}:role/PipelineAdmin"
  category     = "terraform"
  workspace_id = tfe_workspace.services[each.key].id
}
