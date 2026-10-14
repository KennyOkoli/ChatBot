resource "aws_ecs_cluster" "sch_container_cluster" {
    name = "schedule-cluster"
}


/*
data "aws_iam_policy_document" "trust_policy_task_def" {
    statement {
      effect = "allow"
      principals {
        type = "Service"
        identifiers = [""]
    }
    actions = ["sts:AssumeRole"]
}
}

resource "aws_iam_role" "access_ecr" {

}
*/