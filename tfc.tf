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
  name = each.value.git_repo
  organization = tfe_organization.famkraai.name
  vcs_repo {
    identifier         = "${yamldecode(data.aws_s3_object.config.body).github.owner}/${github_repository.services[each.key].name}"
    ingress_submodules = false
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
  
}
