variable "tfc_token" {
  type = string
  sensitive = true
}
variable "github_token" {
  type = string
  sensitive = true
}
variable "aws_key" {
  type = string
  sensitive = true
}
variable "aws_secret" {
  type = string
  sensitive = true
}
variable "aws_ssoandorg_role" {
  type = string
  sensitive = true
}
variable "aws_iam_role" {
  type = string
  sensitive = true
}
variable "aws_s3_role" {
  type = string
  sensitive = true
}
variable "aws_sso_admin_group" {
  type = string
  sensitive = true
}
