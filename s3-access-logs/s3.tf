resource "aws_s3_bucket" "s3accessBucket" {
  bucket = "${var.aws-region}-${data.aws_caller_identity.current.account_id}-s3-access-logs"
  acl    = "log-delivery-write"
  region = "${var.aws-region}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id      = "s3access"
    enabled = true

    tags {
      "rule"      = "s3access"
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
  }}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.s3accessBucket.id}"

  topic {
    topic_arn     = "${aws_sns_topic.topic.arn}"
    events        = ["s3:ObjectCreated:*"]
  }
}