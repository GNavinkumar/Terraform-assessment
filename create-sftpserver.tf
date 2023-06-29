provider "aws" {
    region = "eu-west-1"
    access_key = "AKIAZ7AZ7IQIGZGGI7WD"
    secret_key = "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"
}
resource "aws_transfer_server" "mysftp" {
  identity_provider_type = "SERVICE_MANAGED"

  tags = {
    NAME = "mysftp"
  }
}

data "aws_iam_policy_document" "sftpiamrole" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "myrole" {
  name               = "tf-user-iam-role"
  assume_role_policy = data.aws_iam_policy_document.sftpiamrole.json
}

data "aws_iam_policy_document" "mydoc" {
  statement {
    sid       = "AllowFullAccesstoS3"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "myresource" {
  name   = "tf-iam-policy1"
  role   = aws_iam_role.myrole.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_transfer_user" "myres" {
  server_id = aws_transfer_server.mysftp.id
  user_name = "tftestuser"
  role      = aws_iam_role.myrole.arn

  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/test.pdf"
    target = "/navin-bucket01/test-path/tftestuser.pdf"
  }
}

resource "aws_iam_user" "s3_users" {
  name = "s3-users"
}



resource "aws_iam_policy" "policy1" {
  name   = "policy1"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ReadObject",
        "s3:WriteObject"
      ],
      "Resource": "arn:aws:s3:::navin-bucket01/*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "attachment1" {
  user       = aws_iam_user.s3_users.name
  policy_arn = aws_iam_policy.policy1.arn
}
