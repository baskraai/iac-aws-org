resource "github_repository" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name        = each.value.git_repo
  description = "An IaC AWS rep for the service ${each.value.name}"
  visibility = each.value.testing ? "private" : "public"

  template {
    owner = yamldecode(data.aws_s3_object.config.body).github.owner
    repository = "iac-aws-template"
  }

}
