resource "aws_secretsmanager_secret" "db-secret" {
  name = "db-secret"
}

data "aws_iam_policy_document" "db-secret-trust-policy" {
  statement {
    sid    = "EnableAnotherAWSAccountToReadTheSecret"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["ecs-task.amazonaws.com"]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret_policy" "db_secret_value" {
  secret_arn = aws_secretsmanager_secret.db-secret.arn
  policy     = jsonencode({
       username = var.db-credentials[0]
       password = var.db-credentials[1]
  })
}