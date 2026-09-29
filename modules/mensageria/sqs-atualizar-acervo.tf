resource "aws_sqs_queue" "atualizar_acervo" {
  name                      = "${var.projeto}-atualizar-acervo"
  tags                      = merge(var.application_tags, { Contexto = "Monitoramento" })
  delay_seconds             = 10
  message_retention_seconds = 300
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.atualizar_acervo_deadletter.arn
    maxReceiveCount     = 4
  })
  # kms_master_key_id                 = "alias/aws/sqs"
  # kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue" "atualizar_acervo_deadletter" {
  name = "${var.projeto}-atualizar-acervo-dlq"
  tags = merge(var.application_tags, { Contexto = "Monitoramento" })
  # kms_master_key_id                 = "alias/aws/sqs"
  # kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue_redrive_allow_policy" "atualizar_acervo_redrive_allow_policy" {
  queue_url = aws_sqs_queue.atualizar_acervo.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.atualizar_acervo.arn]
  })
}
