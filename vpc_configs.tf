data "aws_availability_zones" "af-zones" {
    state = "available"
}

resource "aws_vpc" "cloudGPT" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
}

variable "public_subnets_tags" {
    type = list(string)
    default = ["pub-1", "pub-2"]
}

resource "aws_subnet" "public_subnets" {
    count = 2
    vpc_id = aws_vpc.cloudGPT.id
    cidr_block = "32.0.${count.index}.0/24"
    availability_zone = data.aws_availability_zones.af-zones.names[count.index]
    map_public_ip_on_launch = true
    tags ={
        name = var.public_subnets_tags[count.index]
    }
}

resource "aws_internet_gateway" "cloudGPT_gateway" {
    vpc_id = aws_vpc.cloudGPT.id
}

resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.cloudGPT.id
    route{
        cidr_block = var.public_cidr
        gateway_id = aws_internet_gateway.cloudGPT_gateway.id
    }
}

resource "aws_network_acl" "public_nacls" {
    vpc_id = aws_vpc.cloudGPT.id
    subnet_ids = aws_subnet.public_subnets[*].id

    ingress{
        rule_no = 1
        cidr_block = var.public_cidr
        protocol = "tcp"
        action = "allow"
        from_port = 0
        to_port = 65535
    }
    egress{
        rule_no = 2
        cidr_block = var.public_cidr
        protocol = "tcp"
        action = "allow"
        from_port = 0
        to_port = 65535
    }
}

resource "aws_route_table_association" "route_pub_asscociation" {
    count = 2
    route_table_id = aws_route_table.public_route.id
    subnet_id = aws_subnet.public_subnets[count.index].id
}

resource "aws_network_acl_association" "nacls_pub_asociation" {
    count = 2
    network_acl_id = aws_network_acl.public_nacls.id
    subnet_id = aws_subnet.public_subnets[count.index].id
}


# --------------------------- PRIVATE RESOURCES-----------------------------
variable "prv_subnet_tags" {
    type = list(string)
    default = ["prv-1", "prv-2"]
}

resource "aws_subnet" "private_compute_subnets" {
    count = 2
    vpc_id = aws_vpc.cloudGPT.id
    availability_zone = data.aws_availability_zones.af-zones.names[count.index]
    cidr_block = "32.0.${count.index + 100}.0/24"
    tags = {
        name = var.prv_subnet_tags[count.index]
    }
}

resource "aws_route_table" "prv-route" {
    count = 2
    vpc_id = aws_vpc.cloudGPT.id
    route{
        cidr_block = var.public_cidr
        nat_gateway_id = aws_nat_gateway.vpc_natgateway[count.index].id 
    }
}

resource "aws_eip" "nat_eip" {
    count = 2
}

resource "aws_nat_gateway" "vpc_natgateway" {
    count = 2
    allocation_id = aws_eip.nat_eip[count.index].id
    subnet_id = aws_subnet.public_subnets[count.index].id
    tags = {
        name = var.nat_tags[count.index]
    }
}

resource "aws_network_acl" "compute_acl" {
    vpc_id = aws_vpc.cloudGPT.id
    ingress{
        rule_no = 1
        protocol = "tcp"
        cidr_block = var.public_cidr
        action = "allow"
        from_port = 0
        to_port = 65535
    }
    egress{
        rule_no = 1
        protocol = "tcp"
        cidr_block = var.public_cidr
        action = "allow"
        from_port = 0
        to_port = 65535
    }
}


resource "aws_route_table_association" "prv-route-subnet" {
    count = 2
    route_table_id = aws_route_table.prv-route[count.index].id
    subnet_id = aws_subnet.private_compute_subnets[count.index].id
}

resource "aws_network_acl_association" "nacl-prv-subnet" {
    count = 2
    network_acl_id = aws_network_acl.compute_acl.id
    subnet_id = aws_subnet.private_compute_subnets[count.index].id
}