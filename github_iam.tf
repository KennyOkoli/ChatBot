resource "aws_iam_openid_connect_provider" "github-id" {
    url = "https://token.actions.githubusercontent.com"
    client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "trust-policy-github" {
    statement {
      effect = "Allow"
      principals {
        type = "Federated"
        identifiers = [aws_iam_openid_connect_provider.github-id.arn]
        }
      actions = ["sts:AssumeRoleWithWebIdentity"]
      condition {
         test     = "StringEquals"
         variable = "token.actions.githubusercontent.com:aud"
         values = ["sts.amazonaws.com"]
        }
      condition{
         test = "StringLike"
         variable = "token.actions.githubusercontent.com:sub"
         values = ["repo:KennyOkoli/ChatBot_app:*"]
      }
    }
}

resource "aws_iam_role" "github-role" {
    name = "github-role"
    assume_role_policy = data.aws_iam_policy_document.trust-policy-github.json
}

resource "aws_iam_role_policy" "github-role-permission" {
    role = aws_iam_role.github-role.id
    policy = data.aws_iam_policy_document.github-permissions.json
} 

data "aws_iam_policy_document" "github-permissions" {
    statement{
        effect = "Allow"
        actions = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"]
        resources = [aws_ecr_repository.chatbot_repo.arn]
    }
    statement{
        effect = "Allow"
        actions = ["ecr:GetAuthorizationToken"]
        resources = ["*"]
    }
}