provider "aws" {
  access_key = ""
  secret_key = ""
  region     = ""
}

resource "aws_kinesis_stream" "mod" {
  name             = var.stream_name
  shard_count      = var.shard_count
  retention_period = var.retention_period

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
    "OutgoingRecords",
    "ReadProvisionedThroughputExceeded",
    "WriteProvisionedThroughputExceeded",
    "IncomingRecords",
    "IteratorAgeMilliseconds",
  ]
  #  tags {
  #    ForwardToFirehoseStream = "${var.create_s3_backup ? join("",aws_kinesis_firehose_delivery_stream.mod.*.name) : ""}"
  #  }
}

resource "aws_cloudwatch_log_subscription_filter" "kinesis_logfilter" {
  name            = var.subscription_cloudwatch_kinesis
  role_arn        = aws_iam_role.test_role.arn
  log_group_name  = var.log_group
  filter_pattern  = "root"
  destination_arn = aws_kinesis_stream.mod.arn
  distribution    = "Random"
}

#resource "aws_s3_bucket" "bucket" {
#  bucket = "tf-test-bucket"
#  acl    = "private"
#}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name = "terraform-kinesis-firehose-extended-s3-test-stream"

  #  source      = "aws_kinesis_stream.mod.id"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.mod.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  extended_s3_configuration {
    role_arn = aws_iam_role.firehose_role.arn

    #    bucket_arn = "${aws_s3_bucket.bucket.arn}"
    bucket_arn = "arn:aws:s3:::lambdajordan3"

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }
    }
  }
}

resource "aws_lambda_function" "lambda_processor" {
  filename      = "TestlambdaTerraform.zip"
  function_name = "firehose_lambda_processor"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "TestlambdaTerraform.cloudwatch_handler"
  runtime       = "python3.7"
  timeout       = "360"
}

