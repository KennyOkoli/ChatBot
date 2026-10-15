variable "vpc_cidr" {
    type = string
    default = "32.0.0.0/16"
}

variable "public_cidr" {
    type = string
    default = "0.0.0.0/0"
}

variable "nat_tags" {
    default = ["nat-1", "nat-2"]
}

variable "account_id" {
    default = "871145212791"
}

variable "db-credentials" {
    type = list(string)
    default = ["Kenny", "kenny2027"]
}