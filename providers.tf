terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~>6"
        }
        tls = {
            source = "hashicorp/tls"
            version = "~>4"
        }
        local = {
            source = "hashicorp/local"
            version = "~>2.9"
        }
    }
}

provider "aws"{
    region = "af-south-1"
}