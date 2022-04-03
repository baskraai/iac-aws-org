resource "github_repository" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name        = "iac-aws-${lower(each.key)}"
  description = "An IaC AWS rep for the service: ${title(replace(each.key,"_"," "))}"
  visibility  = "private"

  template {
    owner = yamldecode(data.aws_s3_object.config.body).github.owner
    repository = "iac-aws-template"
  }

}
