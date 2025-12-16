# Terraform-basics
Terraform advanced file structure for project level

### for plan
terraform plan -var-file="dev.tfvars"
### ways for varibels
during command or env in terminals

### Variable Definition Precedence
Terraform loads variables in the following order, with later sources taking precedence over earlier ones:
1. Environment variables
2. The terraform.tfvars file, if present.
3. The terraform.tfvars.json file, if present.
4. Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical orde filenames.
5. Any -var and -var-file options on the command line

### data types
we can restrict types by using types to varibales in variables.tf example number, list([]), map({}), etc., 
variable "mylist" {
    type = list(number)
    default = ["1", "2", "3"]
}
variable "mymap" {
    type = map(string)
    default = {"one" = "1", "two" = "2", "three" = "3"}
}
variable "myset" {
    type = set(string)
    default = ["one", "two", "three"]
}
variable "mytuple" {
    type = tuple(string)
    default = ["one", "two", "three"]
}
### how to acces maps and list in code
instance type = var.mylist[2]
instance type = var.mymap["us-east-1"]  its a key value pair

count = 3 for duplication of resources
when using count use dynamic names with count index

### H ow to use count index in resource
resource "aws_instance" "ec2" {
    count = 3
    tags = {
        Name = "ec2-${count.index}"
        project = var.project[count.index]
    }
}
### conditional expression  
resource "aws_instance" "ec2" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = var.env == "dev" ? "t2.micro" : "t2.small"
}
### How to use a builtin functions
```
terraform console
length(var.project)
max(var.project)
min(var.project)
file("path/to/file")
fileset("path/to/directory", "*.txt")

resource "aws_iam_user" "user" {
    name = "user"
}

resource "aws_iam_user_policy" "policy" {
    name = "policy"
    user = aws_iam_user.user.name
    policy = file("iam-user-policy.json")
}
 
```
### How to use locals & locals are private resource
### with locals u can use functions to create dynamic values
locals {
    project = ["dev", "prod", "staging"]
}

resource "aws_instance" "ec2" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = var.env == "dev" ? "t2.micro" : "t2.small"
    tags = {
        Name = "ec2-${count.index}"
        project = local.project[count.index]
        project_tags = local.project_tags
    }
}

### How to use data sources, it fetches data from aws,etc.,
data "aws_instance" "ec2" {
    filter {
        name = "tag:project"
        values = ["cgf"]
    }
}
```
data "aws_ami" "my_image"{
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
}


### 

f

























### Resources crash course
https://github.com/zealvora/terraform-beginner-to-advanced-resource
Terraform extension in vscode
Ansible -- configuration management tool

```

How to choose IAC Tool?
i) Is your infrastructure going to be vendor specific in longer term? Example AWS.
ii) Are you planning to have multi-cloud / hybrid cloud based infrastructure ?
iii) How well does it integrate with configuration management tools ?
iv) Price and Support

```
1. install terraform terraform init
2. for ref doc use registry.terraform.io for aws 
3. if manual changes occurs in aws , terraform changes it to desired satte
4. 2. Resorces(aws services) details are called as attributes.
5. attribute refernce
6. String interpolation in terraform 
7. varibales.tf    for var storage
```
varible "vpn_ip" {
 default= "101.30.13.03/32"
}

# usage var.vpn_ip
```



```
terraform init
terraform fmt
terraform vaildate
# need aws iam credentials in terminal via export
terraform plan
terraform apply --auto-approve
# put .tfstate file in s3 
# using alais u can deploy in other regions 
# use terraform.tfvars for variables declaration
terraform state list
terraform workspace new dev 
# for different environments use above command
terraform providers
# terraform implicit dependency
# terraform depends_on explicit dependency
terraform destroy -target aws_instance.ec2

```

```
# to put .tfstate file in s3 with version enabled add this line in main.tf
terraform{
backend "s3"{
	bucket = "bucketName" 
	key  = "myterraform.tfstate"
	region = "us-east-01"
   }
}

output "public_ip" {
value = 
}
```

