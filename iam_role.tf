resource "aws_iam_role" "test_role" {
  name = "TrustPolicyForCWL"

  assume_role_policy = <<EOF
{
  "Statement": {
    "Effect": "Allow",
    "Principal": { "Service": "logs.${var.aws_region}.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }
}
EOF


  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "test_policy" {
  name = var.iam_role_policy
  role = aws_iam_role.test_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "kinesis:PutRecord",
      "Resource": "arn:aws:kinesis:${var.aws_region}:{arn.account}:stream/RootAccess22"
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::{arn.account}:role/${aws_iam_role.test_role.id}"
    }
  ]
}
EOF

}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iamforlambdaTerraform"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "policy_for_lambda" {
  name = "lambdaaccess"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:DescribeStreamSummary",
                "kinesis:GetRecords",
                "kinesis:GetShardIterator",
                "kinesis:ListShards",
                "kinesis:ListStreams",
                "kinesis:SubscribeToShard",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "firehose_role_policy" {
  name = "firehose_policy"
  role = aws_iam_role.firehose_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "glue:GetTableVersions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::lambdajordan3",
                "arn:aws:s3:::lambdajordan3/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "arn:aws:lambda:eu-west-1:{arn.account}:function:firehose_lambda_processor:$LATEST"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:eu-west-1:{arn.account}:log-group:/aws/kinesisfirehose/terraform-kinesis-firehose-extended-s3-test-stream:log-stream:*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords"
            ],
            "Resource": "arn:aws:kinesis:eu-west-1:{arn.account}:stream/RootAccess22"
        }
    ]
}

EOF

}

