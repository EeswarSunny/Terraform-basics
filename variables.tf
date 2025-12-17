variable "vpn_ip" {
    default = "ami-1234"
}

variable "project_tags" {
    type = map
    sensitive = true
    default = {
        Name = "ec2"
        project = "dev"
    }
}

locals {
    project_tags = {
        Name = "ec2"
        project = "dev"
        creation_date = formatdate("%Y-%m-%d", timestamp())
    }
}
# usage var.vpn_ip 
