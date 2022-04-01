resource "aws_iam_user" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name = "sa_iac-aws-${each.key}"
  path = "/"
  tags = {
    managed = "Terraform"
    repo = yamldecode(data.aws_s3_object.config.body).repo
  }
}

resource "aws_iam_access_key" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  user = aws_iam_user.services[each.key].name
}

resource "aws_iam_user_policy" "services" {
  for_each = yamldecode(data.aws_s3_object.config.body).services
  name = "sa_iac-aws-${each.key}"
  user = aws_iam_user.services[each.key].name
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
