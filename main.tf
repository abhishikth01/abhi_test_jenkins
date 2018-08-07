provider "aws" {
  region     = "us-east-1"
}

variable "tenant_id" {}

resource "aws_iam_policy" "abhi_policy_s3_readonly" {
    name = "abhi_policy_${var.tenant_id}_s3_readonly"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:List*",
            "Resource": "arn:aws:s3:::abhi-ppv-appdata",
            "Condition": {
                "StringLike": {
                    "s3:prefix": ["","abhi-con-${var.tenant_id}/*"],
                    "s3:delimiter": ["/"]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "s3:Get*",
            "Resource": [
                "arn:aws:s3:::abhi-ppv-appdata/abhi-con-${var.tenant_id}/",
                "arn:aws:s3:::abhi-ppv-appdata/abhi-con-${var.tenant_id}/*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role" "abhi_role_support" {
  name = "abhi_role_${var.tenant_id}_support"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::436441654523:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "abhi_s3_role_policy_attach" {
    role       = "${aws_iam_role.abhi_role_${var.tenant_id}_support.name}"
    policy_arn = "${aws_iam_policy.abhi_policy_${var.tenant_id}_s3_readonly.arn}"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"
  acl    = "private"
  region = "us-east-1"

  tags {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "folder" {
    bucket = "${aws_s3_bucket.b.id}"
    acl    = "private"
    key    = "${var.tenant_id}/"
    source = "/dev/null"
}