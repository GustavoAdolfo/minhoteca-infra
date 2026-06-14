resource "aws_cloudwatch_log_group" "default" {
  name              = var.log_route53_group_name
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.kms_log_arn
}



data "aws_iam_policy_document" "query_logging_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:log-group:${var.log_route53_group_name}/*",
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:${var.log_route53_group_name}:*"
    ]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "log_policy" {
  policy_document = data.aws_iam_policy_document.query_logging_policy.json
  policy_name     = var.domain_log_policy
}

resource "aws_route53_query_log" "root" {
  depends_on               = [aws_cloudwatch_log_resource_policy.log_policy]
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.default.arn
  zone_id                  = var.root_zone_id
}
