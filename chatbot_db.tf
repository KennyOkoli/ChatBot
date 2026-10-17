/*resource "aws_db_instance" "chatbot_multi_db" {
    db_name = "Chatbot"
    identifier = "chatbot-db"
    engine = "mysql"
    engine_version = "8.4.11"
    instance_class = "t3.micro"
    storage_type = "gp3"
    allocated_storage = 100
    username = var.db-credentials[0]
    password = var.db-credentials[1]
    multi_az = true
    skip_final_snapshot = true
    db_subnet_group_name = aws_db_subnet_group.db-subnet-group.name
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    parameter_group_name = aws_db_parameter_group.chatbot-db-parameter.name
}

resource "aws_db_subnet_group" "db-subnet-group" {
    name = "db-subnet-group"
    subnet_ids = aws_subnet.db_subnet[*].id
}

resource "aws_subnet" "db_subnet" {
    count = 2
    vpc_id = aws_vpc.cloudGPT.id
    cidr_block = "32.0.${count.index +200}.0/24"
    availability_zone = data.aws_availability_zones.af-zones.names[count.index]

    tags = {
        name = var.db-subnet-tags[count.index]
    }
}

resource "aws_db_parameter_group" "chatbot-db-parameter" {
    name = "chatbot-db-parameter"
    family = "mysql5.6"

    parameter {
      name = "max_connections"
      value = 500
    }
}

resource "aws_security_group" "db_sg" {
    name = "ecs_sg"
    vpc_id = aws_vpc.cloudGPT.id
}

resource "aws_security_group_rule" "db-sg-rule-1" {
    security_group_id = aws_security_group.db_sg.id
    type = "ingress"
    source_security_group_id = aws_security_group.task_sg.id
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
}

resource "aws_security_group_rule" "db-sg-rule-2" {
    security_group_id = aws_security_group.db_sg.id
    type = "egress"
    source_security_group_id = aws_security_group.task_sg.id
    protocol = "tcp"
    from_port = 0
    to_port = 65535
}

variable "db-subnet-tags" {
    default = ["db-1", "db-2"]
}

resource "aws_route_table" "db_route"{
    vpc_id = aws_vpc.cloudGPT.id
}

resource "aws_route_table_association" "db-route-association" {
    count = 2
    route_table_id = aws_route_table.db_route.id
    subnet_id = aws_subnet.db_subnet[count.index].id
}

output "db-endpoint"{
    value = aws_db_instance.chatbot_multi_db.endpoint
}
*/