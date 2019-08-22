variable "stream_name" {
  default = ""
}

variable "create_api_gateway" {
  default = false
}

variable "create_s3_backup" {
  default = true
}

variable "shard_count" {
  default = "1"
}

variable "retention_period" {
  default = "48"
}

variable "environment_name" {
  default = "dev"
}

# variable "application_name" {}

variable "aws_region" {
  default = ""
}

variable "lambda_s3_bucket" {
  default = "lambdajordan3"
}

variable "iam_role_policy" {
  default = "Terraformpolicy"
}

variable "subscription_cloudwatch_kinesis" {
  default = "subcloudwatch"
}

variable "log_group" {
  default = "TerraformKinesis"
}

