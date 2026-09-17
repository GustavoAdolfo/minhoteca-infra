resource "aws_sns_topic" "user_borrow_publisher" {
  name            = "${var.projeto}-alertas-admin"
  display_name    = "Alertas Administrativos"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
  tags = merge(
    var.application_tags,
    {
      Contexto = "Administração"
  })
}
