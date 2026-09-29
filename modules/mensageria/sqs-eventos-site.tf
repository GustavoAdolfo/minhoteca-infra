resource "aws_sqs_queue" "eventos_site" {
  name                      = "${var.projeto}-eventos-site"
  tags                      = merge(var.application_tags, { Contexto = "Monitoramento" })
  delay_seconds             = 10
  message_retention_seconds = 300
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.eventos_site_deadletter.arn
    maxReceiveCount     = 4
  })
  # kms_master_key_id                 = "alias/aws/sqs"
  # kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue" "eventos_site_deadletter" {
  name = "${var.projeto}-eventos-site-dlq"
  tags = merge(var.application_tags, { Contexto = "Monitoramento" })
  # kms_master_key_id                 = "alias/aws/sqs"
  # kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue_redrive_allow_policy" "eventos_site_redrive_allow_policy" {
  queue_url = aws_sqs_queue.eventos_site.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.eventos_site.arn]
  })
}
