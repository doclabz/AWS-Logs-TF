resource "aws_iam_role" "configRole" {
  name = "configRole"

  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "config.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOF
}

resource "aws_iam_role_policy" "configpolicy" {
  name = "awsconfig-example"
  role = "${aws_iam_role.configRole.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.configBucket.arn}",
        "${aws_s3_bucket.configBucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "config-attach" {
  role       = "${aws_iam_role.role.configRole}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}
