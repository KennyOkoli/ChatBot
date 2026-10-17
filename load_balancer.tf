resource "aws_lb" "chatbot_lb" {
    name = "chatbot-url"
    subnets = aws_subnet.public_subnets[*].id
    internal = false 
    load_balancer_type = "application"
    security_groups = [aws_security_group.lb_security_group.id]
}

resource "aws_lb_listener" "chatbot_lb_listener" {
    load_balancer_arn = aws_lb.chatbot_lb.arn
    protocol = "HTTP"
    port = 80
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.lb_target_group.arn
    }
}

resource "aws_lb_target_group" "lb_target_group" {
    vpc_id = aws_vpc.cloudGPT.id
    protocol = "HTTP"
    port = 3000
    target_type = "ip"

    health_check {
      protocol = "HTTP"
      path = "/"
      port = 3000
      interval = 30
      timeout = 7
      healthy_threshold = 3
      unhealthy_threshold = 2
    }
}

resource "aws_security_group" "lb_security_group" {
    vpc_id = aws_vpc.cloudGPT.id
    name = "lb_security_group"
}

resource "aws_security_group_rule" "lb_sg_rule" {
    security_group_id = aws_security_group.lb_security_group.id
    type = "ingress"
    protocol = "tcp"
    cidr_blocks = [var.public_cidr]
    from_port = 80
    to_port = 80
}

resource "aws_security_group_rule" "lb_sg_rule_2" {
    security_group_id = aws_security_group.lb_security_group.id
    type = "ingress"
    protocol = "tcp"
    cidr_blocks = [var.public_cidr]
    from_port = 443
    to_port = 443
}

resource "aws_security_group_rule" "lb_sg_rule_3" {
    security_group_id = aws_security_group.lb_security_group.id
    source_security_group_id = aws_security_group.task_sg.id
    type = "egress"
    protocol = "tcp"
    from_port = 3000
    to_port = 3000
}
