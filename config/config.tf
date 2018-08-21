resource "aws_config_delivery_channel" "channel" {
  name           = "configDelivery"
  s3_bucket_name = "${aws_s3_bucket.configBucket.id}"
  sns_topic_arn  = "${aws_sns_topic.topic.arn}"
  depends_on     = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = "configRecorder"
  role_arn = "${aws_iam_role.configRole.arn}"
}

resource "aws_config_configuration_recorder_status" "recorderStatus" {
  name       = "${aws_config_configuration_recorder.recorder.name}"
  is_enabled = true
  depends_on = ["aws_config_delivery_channel.channel"]
}
