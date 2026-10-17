resource "aws_secretsmanager_secret" "db-secret" {
  name = "Chatdb-secret"
}

/*data "aws_iam_policy_document" "db-secret-trust-policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}
*/
resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db-secret.id
  secret_string = jsonencode({
       username = var.db-credentials[0]
       password = var.db-credentials[1]
  })
}
