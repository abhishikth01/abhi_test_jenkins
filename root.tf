resource "aws_iam_policy" "abhi_policy_tenant94_s3_readonly" {
    name = "abhi_policy_tenant94_s3_readonly"
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
                    "s3:prefix": ["","abhi-con-tenant94/*"],
                    "s3:delimiter": ["/"]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "s3:Get*",
            "Resource": [
                "arn:aws:s3:::abhi-ppv-appdata/abhi-con-tenant94/",
                "arn:aws:s3:::abhi-ppv-appdata/abhi-con-tenant94/*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role" "abhi_role_tenant94_support" {
  name = "abhi_role_tenant94_support"

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

resource "aws_iam_role_policy_attachment" "abhi_policy_tenant94_s3_readonly" {
    role       = "${aws_iam_role.abhi_role_tenant94_support.name}"
    policy_arn = "${aws_iam_policy.abhi_policy_tenant94_s3_readonly.arn}"
}