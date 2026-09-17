resource "aws_sqs_queue" "replica_usuario" {
  name                      = "${var.projeto}-replica-usuario"
  tags                      = merge(var.application_tags, { Contexto = "Empréstimos" })
  delay_seconds             = 10
  message_retention_seconds = 300
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.replica_usuario_deadletter.arn
    maxReceiveCount     = 4
  })
  # kms_master_key_id                 = "alias/aws/sqs"
  # kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue" "replica_usuario_deadletter" {
  name = "${var.projeto}-replica-usuario-dlq"
  tags = merge(var.application_tags, { Contexto = "Empréstimos" })
  # kms_master_key_id                 = "alias/aws/sqs"
  # kms_data_key_reuse_period_seconds = 300
}

resource "aws_sqs_queue_redrive_allow_policy" "replica_usuario_redrive_allow_policy" {
  queue_url = aws_sqs_queue.replica_usuario.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.replica_usuario.arn]
  })
}
