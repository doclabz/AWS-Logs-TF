resource "aws_s3_bucket" "configBucket" {
  bucket = "${var.aws-region}-${data.aws_caller_identity.current.account_id}-config"
  acl    = "private"
  region = "${var.aws-region}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id      = "config"
    enabled = true
    prefix  = "AWSLogs/"

    tags {
      "rule"      = "config"
      "autoclean" = "true"
    }

    transition {
      days          = 15
      storage_class = "GLACIER"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = "${var.aws-region}-${data.aws_caller_identity.current.account_id}-s3-access-logs"
    target_prefix = "${var.aws-region}-${data.aws_caller_identity.current.account_id}-config/"
  }

  tags {
    Name = "${var.aws-region}-${data.aws_caller_identity.current.account_id}-config"
  }
}

resource "aws_s3_bucket_policy" "configBucketPolicy" {
  bucket = "${aws_s3_bucket.configBucket.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [

      {
      "Sid": "Require SSL",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.configBucket.arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }, 
    {
      "Sid": "Allow config to write to bucket",
      "Effect": "Allow",
      "Principal": {
        "Service": [
         "config.amazonaws.com"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.configBucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Sid": "Allow bucket ACL check",
      "Effect": "Allow",
      "Principal": {
        "Service": [
         "config.amazonaws.com"
        ]
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.configBucket.arn}",
    }
  ]
}
POLICY
}
