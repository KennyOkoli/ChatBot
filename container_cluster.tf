resource "aws_ecs_cluster" "gpt_container_cluster" {
    name = "Chatbot-cluster"
}

resource "aws_ecr_repository" "chatbot_repo" {
    name = "chatbot-repo"
    image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecs_task_definition" "chatbot_task_def" {
    family = "chatbot_main"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = 256
    memory = 512
    execution_role_arn = aws_iam_role.access_ecr.arn

    container_definitions = jsonencode([
        {
        name = "chatbot"
        image = "nginx:latest"
        essential = true
        portMappings = [{
            containerPort = 3000
           }]
        }
        ]
    )
}

resource "aws_ecs_service" "chatbot_ecs" {
    name = "chatbot-ecs"
    cluster = aws_ecs_cluster.gpt_container_cluster.id
    task_definition = aws_ecs_task_definition.chatbot_task_def.arn
    desired_count = 2
    launch_type = "FARGATE"
    

    load_balancer {
      target_group_arn = aws_lb_target_group.lb_target_group.arn
      container_name = "chatbot"
      container_port = 3000
    }

    network_configuration {
      subnets = aws_subnet.private_compute_subnets[*].id
      security_groups = [aws_security_group.task_sg.id]
    }

    lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

resource "aws_security_group" "task_sg" {
    name = "task_sg"
    vpc_id = aws_vpc.cloudGPT.id
}

resource "aws_security_group_rule" "task_sg_1" {
    security_group_id = aws_security_group.task_sg.id
    type = "ingress"
    source_security_group_id = aws_security_group.lb_security_group.id
    protocol = "tcp"
    from_port = 3000
    to_port = 3000
}

resource "aws_security_group_rule" "task_sg__egress_2" {
    security_group_id = aws_security_group.task_sg.id
    type = "egress"
    source_security_group_id = aws_security_group.lb_security_group.id
    protocol = "tcp"
    from_port = 0
    to_port = 65535
}

resource "aws_security_group_rule" "task_sg__egress_3" {
    security_group_id = aws_security_group.task_sg.id
    type = "egress"
    cidr_blocks = [var.public_cidr]
    protocol = "tcp"
    from_port = 0
    to_port = 65535
}

#-------------------------IAM---------------------
data "aws_iam_policy_document" "trust_policy_ecs" {
    statement {
      effect = "Allow"
      principals {
        type = "Service"
        identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "access_ecr" {
    name = "access_ecr"
    assume_role_policy = data.aws_iam_policy_document.trust_policy_ecs.json
}

resource "aws_iam_role_policy" "access_ecr_policy" {
    name = "access_ecr_policy"
    role = aws_iam_role.access_ecr.id
    policy = data.aws_iam_policy_document.access_ecr_policy_doc.json
}

data "aws_iam_policy_document" "access_ecr_policy_doc" {
    statement {
      effect = "Allow"
      actions = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetAuthorizationToken"
      ]
      resources = [
        aws_ecr_repository.chatbot_repo.arn,
        "*"
        ]
    }
}


#-----------------------------TASK IAM ROLE-------------------------------
/*resource "aws_iam_role" "task_role" {
    name = "task_role"
    assume_role_policy = data.aws_iam_policy_document.trust_policy_ecs.json
}

resource "aws_iam_role_policy" "task_policy" {
    name = "task_policy"
    role = aws_iam_role.task_role.id
    policy = data.aws_iam_policy_document.task_policy_doc.json
}

/*
data "aws_iam_policy_document" "task_policy_doc" {
    statement {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = [aws_secretsmanager_secret.db-secret.arn]
    }
}
*/