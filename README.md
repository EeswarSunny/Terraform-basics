# 01 Jan 2026 Terraform Cheatsheet (Commands, Codes & Steps)
Terraform advanced file structure for project level

### Terraform basic commands

```
terraform init
or 
terraform init -upgrade
terraform fmt
terraform validate
terraform plan

or 
terraform plan -out ec2.plan     
# its like a version of plan
terraform show -json ec2.plan | jq
terraform apply 
or 
terraform apply ec2.plan
<!-- terraform destroy -->
```
### Terraform loads all configuration files in a directory as a single unit

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
### How to acces maps and list in code
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
        values = ["al2023-ami-ecs-hvm*"]
    }
}
resource "aws_instance" "ec2" {
    ami = data.aws_ami.my_image.id
    instance_type = "t2.micro"
}
``` 
### ssh verbosity
ssh -vvv -i dpa_rsa@192.123.94.34

### How to debug in terraform
log level = debug
log level = trace
log level = info
log level = warn
log level = error
```
export TF_LOG="TRACE"
export TF_LOG_PATH="./terraform.log"

```

### How to troubleshoot terraform
1. language error
2. state error
3. core errors
4. provider errors

### How to create dynamic block
```
variable "sg_ports" {
    type = list(number)
    default = [80, 443, 22]
}

resource "aws_security_group" "dynamicsg" {
    name = "dynamic-sg"
    description = "sg"

    dynamic "ingress" {
        for_each = var.sg_ports
        iterator = port
        content {
            from_port = port.value
            to_port = port.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}
```
### Terraform options
```
terraform apply -replace="aws_instance.ec2"
# destroys and recreate the resource
terraform state rm aws_instance.ec2
# remove the resource from state
terraform state show aws_instance.ec2
# show the resource from state
terraform state list
# list the resources in state
terraform state pull
# pull the state from s3
terraform state push
# push the state to s3

```
### terraform spalat expression allows us to get a list of all attributes
```
resource "aws_iam_user" "user" {
    name = "user.${count.index}"
    count = 3
    path = "/system/"
}

output "arns" {
    value = aws_iam_user.user[*].arn
}
```
### Terraform graph
```
terraform graph
terraform graph | dot -Tsvg > graph.svg
cat graph.svg
terraform graph -draw-cycles

# use graphviz locally  to visualize the graph
```
### terraform workspace
```
terraform workspace new dev
terraform workspace select dev
terraform workspace list
```
### terraform output
```
resource "aws_iam_user" "user" {
    name = "user.${count.index}"
    count = 3
    path = "/system/"
}

output "iam_arn" {
    value = aws_iam_user.user[*].arn
}
# to see output of a specific output
terraform output iam_arn
# to see all outputs
terraform output

```
### terraform settings 
```
terraform {
    required_version = ">= 1.14"
}
```

### How to target a single resource 
terraform plan -target=aws_instance.ec2 
terraform apply -target=aws_instance.ec2 
terraform destroy -target=aws_instance.ec2 
<!-- use with caution   -->

### How to avoid api throttling 
use terraform plan/apply with target to avoid api throttling or divide into small projects
or use terraform plan -refresh=false

### How to use zipmap function
 ```
 # in terraform console
 zipmap(["a", "b", "c"], [1, 2, 3])
 # output
 {
    "a" = 1
    "b" = 2
    "c" = 3
 }

 ```
### How to add comment
```
# this is a comment
/* this is a comment */
// this is a comment
```
### How to add meta arguments
depe
```
resource "aws_instance" "ec2" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    tags = {
        Name = "ec2"
    }
    lifecycle {
        ignore_changes = [tags]    
        # changes made manually and by terraform is ignored
        create_before_destroy = true
        prevent_destroy = true
        replace_triggered_by = [aws_security_group.allow_tls]

    } 
    depends_on = [aws_security_group.allow_tls]
    count = 3
    for_each = toset(["dev", "prod", "staging"])
    provider = "aws.dev"
}
```
### How to use Resource dependency
```
resource "aws_instance" "ec2" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    tags = {
        Name = "ec2"
    }
    depends_on = [aws_s3_bucket.bucket]
}
```
### How to use implicit dependency % explicit dependency
```
# above dependency example is explicit dependency
# implicit dependency example
resource "aws_instance" "ec2" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    tags = {
        Name = "ec2"
    }
    vpc_security_group_ids = [aws_security_group.prod.id] 
    # above line of dependency is implicit dependency
}

resource "aws_security_group" "prod" {
    name        = "prod-sg"
    description = "Allow TLS inbound traffic and all outbound traffic"
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
```
### How to use set(unique) data type
```
variable "user" {
    type = set(string)
    default = ["john", "jane", "doe"]
}
resource "aws_iam_user" "user" {
    # use for each with a set directly
    for_each = var.user
    name = "user-${each.value}"
    path = "/system/"
}

output "user_arn" {
    value = aws_iam_user.user[*].arn
}

```
### How to use for_each with map    
```
variable "map" {
    type = map(string)
    # or 
    # type = map # then anything can be written but above only string is allowed
    # type = object({
    #     name = number
    #     email = string
    # })   # this can also be written for exact type usage in object
    default = {
        "john" = "john@example.com"
        "jane" = "jane@example.com"
        "doe" = "doe@example.com"
    }

}

resource "aws_instance" "ec2" {
    for_each = var.map
    ami = each.value
    instance_type = "t2.micro"
    tags = {
        Name = each.key
    }    
}
```
### terraform provisioners
```
# remote-exec local-exec
resource "aws_instance" "ec2" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    tags = {
        Name = "ec2"
    }    
    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("~/.ssh/id_rsa")
    }
    provisioner "remote-exec" {
        inline = [
            "echo 'Hello, World!' > index.html",
            "aws s3 cp index.html s3://my-bucket"
        ]
        when = "create"
    }
    provisioner "local-exec" {
        when = "destroy"
        on_failure = "continue"
        # on_failure = "fail"
        command = "echo 'Hello, World!' > index.html"
        inline = [
            "echo 'Hello, World!' > index.html",
            "echo ${self.public_ip} >> server_ip.txt"
        ]
    }
}

```
### How to use trusted modules by terraform parters
```
module "ec2" {
    source = "./modules/ec2"
    ami = "ami-0c55b159cbfafe1f0" 
}
# modules are predefined resources
```
### How to use child module outputs
```
module "ec2" {
    source = "./modules/ec2"
    ami = "ami-0c55b159cbfafe1f0" 
}
resource "aws_eip" "lb"{
    instance = module.ec2.instance_id
    domain = "vpc"
}
```
### Basics of standard Module Structure
diffrent modules for diffrent resources ex: Network, Web, App, Database, Routing, Security, Storage, etc.

### How to use multiple provider config in modules
using alias feature
```
provider "aws" {
    alias = "dev"
    region = "us-east-1"
}
provider "aws" {
    alias = "prod"
    region = "us-east-2"
}

```
### Requirement for publishing modules
| Requirement | Description |
| Github | The module must be on GitHub and must be a public repo. This is only a requirement for the public registry. |
| Named |  Module repositories must use this three-part name format terraform-Provider>-<Name> |
| Repository Description |   he GitHub repository description is used to populate the short description of the module. |
| Standard module structure | The module must adhere to the standard module structure. |
| x.y.z tags for releases | The registry uses tags to identify module versions. Release tag names must be a semantic version, which can optionally be prefixed with a v. For example, v1.0.4 and 0.9.2 |

### Tree Structure
$ tree minimal-module/
.
├── README.md
├── main.tf
├── variables.tf
└── outputs.tf

$ tree complete-module/
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── ...
├── modules/
│   ├── nestedA/
│   │   ├── README.md
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── nestedB/
│   ├── .../
├── examples/
│   ├── exampleA/
│   │   ├── main.tf
│   ├── exampleB/
│   ├── .../

### How to use diff values in workspaces
```
locals {
    instance_type = {
        default = "t2.micro"
        "prod" = "t2.large"
        "dev" = "t2.micro"
    }
}

resource "aws_instance" "ec2" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = local.instance_type[terraform.workspace]  
}

```

### How to use workspaces
```
terraform workspace new dev
# use terraform workspace to get list of commnds 
terraform workspace list
terraform workspace select dev
terraform workspace delete dev
terraform workspace show

```
# Section 7 Remote state management

! always use git for collaboration along with gitignore file to avoid data leaks and use s3 for backend 

### How to s3 backend 
```
terraform {
    backend "s3" {
    bucket = "eeswar-terraform-state"
    key = "terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
    dynamodb_table = "eeswar-terraform-lock"
    profile = "eeswar"
  }
}
```

### State locking
```
resource "time_sleep" "wait_100_seconds" {
    create_duration = "100s"
}

```

### terraform state management
```
terraform state list
# to list all resources in state
terraform state pull
# to pull state from s3
terraform state rm aws_instance.ec2
# from now on terraform doesnt manage aws_instance.ec2
terraform state mv aws_instance.ec2 aws_instance.ec2_new
# to move/rename aws_instance.ec2 to aws_instance.ec2_new
terraform state show aws_instance.ec2
# to show state of aws_instance.ec2
terraform state replace aws_instance.ec2
# to replace aws_instance.ec2
terraform state rm aws_instance.ec2
# to remove aws_instance.ec2
terraform state mv aws_instance.ec2 aws_instance.ec2_new
# to move aws_instance.ec2 to aws_instance.ec2_new
terraform state show aws_instance.ec2
```
### How to use remote state data source
```
data "terraform_remote_state" "eip{
    backend = "s3"
    config = {
        bucket = "eeswar-terraform-state"
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}
outputs "eip_addr" {
    value = aws_eip.eip_addr
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4"{
 security_group_id = aws_vpc_security_group.allow_tls.id
 cidr_ipv4 = "${data.terraform_remote_state.eip.outputs.eip_addr}/32"
 ip_protocol = "tcp"
 from_port = 443
 to_port = 443
}

```
### how to use terraform import
```
import {
    to = aws_security_group.my_sg
    id = "sg-0c55b159cbfafe1f0"
}
# after that you apply dynamic plan

terraform plan -generate-config-out=my_sg.tf
terraform apply

# above command will update state file with imported resource
# now you can use this resource in your code with terraform 1.5
```
# Section 8 Security Primer

### How to use alias meta-argument
```
provider "aws" {
    alias = "dev"
    region = "us-east-1"
}
provider "aws" {
    alias = "prod"
    region = "us-east-2"
}

resource "aws_instance" "ec2" {
    provider = "aws.dev"
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
}

resource "aws_instance" "ec2" {
    provider = "aws.prod"
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
}

```
### How to use sensitive parameter
```
variable "password" {
    type = string
    sensitive = true
}
# for sensitive variables terraform will throw error if use it in outputs if you want to use it in outputs use 
output "password" {
    value = var.password
    sensitive = true
}

```
### How to use terraform(HashiCorp) vault, its like aws secrets manager
```
terraform apply -var="password=${vault_password}"
# it creates temp credentials and use it to fetch secrets from vault

provider "vault" {
    address = "http://127.0.0.1:8200"
    token = "my-token"
}
data "vault_generic_secret" "password" {
    path = "secret/data/my-secret"
}

```
###  How to use dependency lock
```
# its done automatically below is the file related to it
.terraform.lock.hcl

```
# Section 9 HCP (HashiCorp Cloud Platform) cloud & Enterprise
its like a ci/cd platform for infra as code
### HCP Terraform pricing
https://www.hashicorp.com/en/pricing?tab=terraform

### HCP Terraform features
1. organizations
all companies uses only above feature not below features commonly
2. Workspaces
    1. version Control Workflow
    2. CLI-driven Workflow
    3. API-driven Workflow
3. Projects
4. Team Management
5. 
### Sentinal (Policy as Code)
it is same as scp (service control policy) in aws 

### Air gap in terraform cloud
It ensures that data can only be accessed or transferred locally, preventing remote cyberattacks and unauthorized data exfiltration.

### HCP Terraform private Reistry
its like aws ecr but for terraform modules


# Section 10 Terraform Challenges use trial and error method to solve challenges

### Challenge 1 ip should be created in aws , you can modify your code as you like 
```
provider "aws" {
  version = "~> 2.54"
  region  = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

provider "digitalocean" {}

terraform {
    required_version = "0.12.31"
}


resource "aws_eip" "eeswar_app_ip" {
  vpc      = true
}
```
### challenge 2 optimize the code for best practices and resource should be created
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"

    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "splunk" {
  default = "8088"
  # modify 8088 to 8089 using variable precedence
}
resource "aws_security_group" "security_group_payment_app" {
  name        = "payment_app"
    description = "Application Security Group"
  depends_on = [aws_eip.example]

# Below ingress allows HTTPS  from DEV VPC
  ingress {
       from_port        = 443
     to_port          = 443
    protocol         = "tcp"
      cidr_blocks      = ["172.31.0.0/16"]
  }

# Below ingress allows APIs access from DEV VPC

  ingress {
    from_port        = 8080
      to_port          = 8080
    protocol         = "tcp"
       cidr_blocks      = ["172.31.0.0/16"]
  }

# Below ingress allows APIs access from Prod App Public IP.

  ingress {
    from_port        = 8443
      to_port          = 8443
    protocol         = "tcp"
       cidr_blocks      = ["${aws_eip.example.public_ip}/32"]
  }
}
 egress {
    from_port        = var.splunk
    to_port          = var.splunk
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }



resource "aws_eip" "example" {
   domain = "vpc"
}

```
### challenge 3  according to the values of map create resources  and if map values removed , ec2 instance should be deleted
```
# main.tf
variable "instance_config" {
  type = map
  default = {
    instance1 = { instance_type = "t2.micro", ami = "ami-03a6eaae9938c858c" }
    instance2 = { instance_type = "t2.small", ami = "ami-053b0d53c279acc90" }
  }
}
# providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

```
### challenge 4 
```
.gitkeep file
1. Clients wants a code that can create IAM user in AWS account with following
syntax:
admin-user-{account-number-of-aws}
2. Client wants to have a logic that will show names of ALL users in AWS account in the output.
3. Along with list of users in AWS, client also wants Terraform to show Total number of users in AWS.
```

### Solution 1
```

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.71.0"
    }
  }
}

variable "do_token" {
    type = string
    sensitive = true
}

provider "digitalocean" {
  token = var.do_token
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
    region     = "us-east-1"
    profile = "eeswar"
    # credentials are given in variables at terminal level
}
resource "aws_eip" "lb" {
  domain   = "vpc"
}
```
### Solution 2
```
# use providers.tf  sg.tf variables.tf terraform.tfvars eip.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"

    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "payment_app" {
  name        = "payment_app"
  description = "Application Security Group"
  depends_on = [aws_eip.example]
  

 # Below ingress allows HTTPS  from DEV VPC
  ingress {
    description = "HTTPS access from DEV VPC"
    from_port        = var.https
    to_port          = var.https
    protocol         = "tcp"
    cidr_blocks      = [var.dev_vpc]
  }

 # Below ingress allows APIs access from DEV VPC

  ingress {
    description = "APIs access from DEV VPC"
    from_port        = var.apis
    to_port          = var.apis
    protocol         = "tcp"
    cidr_blocks      = [var.dev_vpc]
  }

 # Below ingress allows APIs access from Prod App Public IP.

  ingress {
    description = "APIs access from Prod App Public IP"
    from_port        = var.prod_apis
    to_port          = var.prod_apis
    protocol         = "tcp"
    cidr_blocks      = ["${aws_eip.example.public_ip}/32"]
  }
  egress {
    description = "Splunk access from all VPC"
    from_port        = var.splunk
    to_port          = var.splunk
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "payment_app"
    Team = "Payments Team"
    Env = "Dev"
  }
}
 

resource "aws_eip" "example" {
   domain = "vpc"
   tags = {
    Name = "payment_app"
    Team = "Payments Team"
    Env = "Dev"
  }
}

# below values in varibales.tf
variable "https" {}
variable "apis" {}
variable "splunk" {
    default = "8088"
}
# use terraform plan -var="splunk=8089" to override default value
variable "prod_apis" {}
variable "dev_vpc" {}

# below values in terraform.tfvars
https = "443"
apis = "8080"
prod_apis = "8443"
dev_vpc = "172.32.0.0/16"

```
### Solution 3
```
# main.tf
variable "instance_config" {
  type = map
  default = {
    instance1 = { instance_type = "t2.micro", ami = "ami-03a6eaae9938c858c" }
    instance2 = { instance_type = "t2.small", ami = "ami-053b0d53c279acc90" }
  }
}

resource "aws_instance" "example" {
    for_each = var.instance_config
    ami           = data.aws_ami.ubuntu.id
    instance_type = each.value.instance_type

  tags = {
    Name = "HelloWorld"
  }
}


# providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```
### Solution 4
```
# 2
provider "aws" {
  region = "us-east-1"
}
data "aws_iam_users" "users" {}

outputs "user_names"{
  value = data.aws_iam_users.users.names
}
# 3 
output "total_users" {
    value = length(data.aws_iam_users.users.names)
}
#1 
data "aws_caller_identity" "current" {}

resource "aws_iam_user" "admin-user-${data.aws_caller_identity.current.account_id}" {
    name = "admin-user-${data.aws_caller_identity.current.account_id}"
    path = "/system/"
}


```

# Section 11 terraform associate exam
### associate exam requirements
1. physical governament id card is required to show during the exam
2. recommended to have 2 another ids with larger text of name
3. check your system compatability in chrome for exam 
4. pyhysical space 
      Room Requirements
    No one else is permitted to be in your testing room for the duration of your exam.
    Be sure your space is adequately lit, so the proctor can see you and your space.
    Your desk and work area must be clear.
    Any electronics in the room must not be operational.
    Background noise must be as limited as possible.
    No phones, smartwatches, or other similar devices are allowed in the room.
    ***can be called same as aws exam***
5. Make sure there are no notification that appear on your screen while giving the exams.
6. Always verify the updated guidelines released by HashiCorp for the exams to ensure you get the latest update before sitting for the exams.
7. https://hashicorp-certifications.zendesk.com/hc/en-us/articles/26234761626125-Exam-appointment-rules-and-requirements
8. 

### sample notes
1. provider block is not mandatory
2. different aliases can be used for the same provider
3. store creds outside of terraform like env
4. required_provider is only for specifying name & version of provider, for specs of providers use provider block.
5. required_version = "2.0" is for locking the terraform version
6. there are 3 provider tiers 1.Official 2. Partner 3. Community
7. terraform init -upgrade is used for upgrade of versions within constraints.
8. terraform plan does nit modify anything even in state file it just shows the changes that will be made.
9. terraform plan -out is  used to save the plan 
10. terraform apply --auto-approve is used for applying the changes. and it doesnt import any resource.
11. terraform destroy is used for destroying the resources & terraform apply can also be used for destroying the resource
12. terraform fmt is use for formatting the code
13. terraform fmt -check is used for read operation
14. terraform fmt -recursive is used for write operation sub directories also
15. terraform validate is used for validating syntax of the code
16. terraform refresh is depreciated and unsafe
17. resource block reference name must be unique
18. array data types are not supported in terraform
19. terraform state sub-commands  list, mv, pull, push, rm, show
20. note that env variable are there for log like TF_LOG, TFLOG_PATH 
21. terarform import is used for importing existing resources from remote
22. locals values are used when u want to avoid repetition of code & it can reference variables and other locals also
23. terraform workspace is used for managing multiple environments
24. terraform module is used for reusing the code
module "ec2" {
  source = "terraform-aws-modules/vpc/aws"
}
25. local paths do not support versions of modules
26. root and child module difference
27. git::   by using that use can use git repos as modules
28. module output  format : module.module_name.output_name
29. module versions can be used by specifying version in module block
30. terraform registry , module address format : hostname/namespace/name/system
31. user-defined functions are not suppoerted , available ones are , numeric, string, collection, filesysytem functions
| Function Categories | Functions Available |
|Numeric Functions | abs, ceil, floor, max, min |
|String Functions | concat, replace, split, join, tolower, toupper |
|Collection Functions | element, keys, length, merge, sort, slice |
|Filesystem Functions | file, filebase64, dirname |

|ex: lookup function  | ex: zipmap function |
|lookup({
    "apple" = "red"
    "banana" = "yellow"
}, "apple")
red| zipmap(["a", "b"], [1, 2])
{a=1, b=2}|
|ex: index function  | ex: element function |
| index(["a", "b"], 1)
"b" | element(["a", "b"], 0)
"a" |
|ex: toset function| ex: timestamp function  |
|toset(["c", "b", "a"])
{a, b, c}| formatdate(timestamp(), "YYYY-MM-DD")
"2021-09-01" |
|ex: file function  | ex: filebase64 function |
| file("/path/to/file")
"file contents" | filebase64("/path/to/file")
"base64 encoded file contents" |
|ex: keys function  | ex: length function |
| keys({"a" = 1, "b" = 2})
["a", "b"] | length(["a", "b"])
2 |
|ex: merge function  | ex: sort function |
| merge({"a" = 1, "b" = 2}, {"b" = 3, "c" = 4})
{"a" = 1, "b" = 3, "c" = 4} | sort(["a", "b", "c"])
["a", "b", "c"] |
|ex: slice function  | ex: zipmap function |
| slice(["a", "b", "c"], 1, 2)
["b", "c"] | zipmap(["a", "b"], [1, 2])
{a=1, b=2} |
|ex: sort function  | ex: dirname function |
| sort(["a", "b", "c"])
["a", "b", "c"] | dirname("/path/to/file")
"/path/to" |
|ex: filebase64 function  | ex: filebase64sha256 function |
| filebase64("/path/to/file")
"base64 encoded file contents" | filebase64sha256("/path/to/file")
"base64 encoded file contents sha256" |

32. Meta arguments in terraform 
  1. depends_on   description: used for explicit dependency
  2. count description: used for creating multiple resources
  3. for_each description: used for creating multiple resources
  4. provider  desc: used for specifying provider
  5. lifecycle desc: used for managing resource lifecycle
     1. create_before_destroy  desc: used for creating resource before destroying
     2. prevent_destroy desc: used for preventing resource deletion
     3. ignore_changes desc: used for ignoring changes
     4. replace_triggered_by desc: used for replacing resource 
33. sectinal checks : runs before plan
34. terraform graph : visual representation of resources note dot format
35. terraform tvfars : used for variables declaration > variables.tf > terraform.tfvars or dev.tfvars
36. order variable defaults < *.tfcars < env variables < CLI variables   :::: env example export TF_VAR_vpn_ip="101.30.13.03/32"  in linux
37. precedence -var in cli overerides *.auto.tfvars or *.auto.tfvars.json overerides terraform.tfvars.json overrides terraform.tfvars overerides env variables
38. use outputs to store data about resource in state file
39. terraform console : used for interactive mode
40. dependency lock file : used for locking the version of the provider
41. implecent vs explicit dependency : **Implicit** dependencies are created **automatically** when resources share data (referencing an ID), while **Explicit** dependencies are created **manually** using `depends_on` to force a specific order.
42. features of Terraform enterprise plan
    1. sso
    2. auditing 
    3. private data center networking
    4. clustering
    5. Team & Governance feature are not available in terraform cloud free tier
    6. explore more on https://www.hashicorp.com/en/pricing?tab=terraform 
43. HCP Hashicorp cloud platform , it also has private module registry
44. encryption of state file is also available in saas of hcp
45. Hcp workspace linked to version controlled repository(single branch)  then it runs auto on source code changes
46. terraform apply -replace="aws_instance.ec2" : used for replacing resource
47. Benefits of terraform iac 
    1. Automation
    2. Version control
    3. Reusability
48. modules of git registry : uses default branch u can also override it : git::https://github.com/terraform-aws-modules/vpc.git?ref=tags/v3.11.0
49. splat expressions : used for accessing multiple values from a list or map : aws_instance.ec2[*].id
50. list usage : var.list_of_values[0]
51. map usage : var.map_of_values["key"]
52. Large Infra: Break the infrastructure into separate state files (splitting the state) to prevent API rate limiting and reduce blast radius.
53. backend : used for storing state file in remote storage :  migrate backend option is there
54. Air Gapped environemnet isolation : isolates physical hardware from internet
55. requirements for publishing Module in registry : 1. Github, 2. Named terraform-<Provider>-<Module Name> 3. Repo desc, 4. Standard Module structure 5. x.y.z tags for releases
56. disadvantage of dynamic block : hard to read & maintain
57. api & cli access for terraform is through tokens
58. terrafomr uses parallelism to speed up the execution
59. terraform providers can be installed through airgapped systems
60. terraform & terrafomr provider doesnt need major version compatability
61. ! sensitive values are visible in state file 
62. during state lock : plan, destroy, apply, refresh, and other state commands are blocked
63. go through terraform .gitignore file for more info
64. terraform force-unlock <lock-id> : used for unlocking state file
65. Data Type of Object & Multiple Provider Configuration in Modules are important for exam
66. make use of Data Source for dynamic ami_id
67. output values are defined in the Child and Root modules: When you run terraform apply it shows output values of root module without explicit call to teh child module.
68. if variable typr is string and value is number then it converts to string automatically
69. to migrate the Terraform state file from localhost to S3 bucket you need terraform init command not any other
70. Terraform will not store the default value of the variable and its description in the Terraform state file
71. 






 





 






































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








To make your GitHub repository appear in Google search results (a process known as Search Engine Optimization or SEO), you need to make it easily discoverable and ensure Google's web crawlers can index it.
Here is what you should do to increase the visibility of your repository: https://github.com/EeswarSunny/Terraform-basics.

1. Optimize Your GitHub Repository
Google indexes GitHub pages like any other website. Optimizing your repo's content and metadata is crucial.
Choose a Clear, Descriptive Name: Your current name, Terraform-basics, is good. It clearly states the topic.
Write a Concise Description: In your repository settings, write a short, keyword-rich description (e.g., "A comprehensive Terraform cheat sheet for beginners in 2026, covering HCL, CLI commands, state management, and best practices.").
Add Relevant Topics/Tags: Utilize GitHub's topic feature (located on the right sidebar of the repo page) and add relevant tags like terraform, cheat-sheet, devops, infrastructure-as-code, hcl, and iaas. This helps categorize your repository for both GitHub users and search engines.
Create a High-Quality README.md: The content of your README is the most important part for SEO.
Ensure the title clearly uses keywords (e.g., # Terraform Cheat Sheet 2026).
Provide detailed, useful content. Google favors relevant and comprehensive content.
Organize the information logically with headers, bullet points, and code snippets.
Ensure the Repository is Public: Google can only index public repositories. Double-check your settings to ensure it is not private.

2. Build Backlinks (External Links)
The number and quality of links pointing to your repository tell Google that your content is valuable and authoritative. This is a primary driver of search rankings.
Share on Social Media: Post links to your repository on platforms like LinkedIn, Twitter, and Reddit (in relevant communities like r/terraform or r/devops).
Contribute to Related Discussions: If you are active on forums, blogs, or Q&A sites (like Stack Overflow), mention your cheat sheet as a resource when relevant to a discussion, linking back to your GitHub repo.
List it on Resource Curations: Once your repo is mature, ask for it to be included in existing "Awesome Lists" for Terraform or DevOps (collections of useful resources curated by the community).
Blog About It: Write a blog post on a platform like Medium, Dev.to, or your own blog about creating the cheat sheet and link to the GitHub repository as the primary source.

3. Be Patient
Google does not index new pages instantly.
It can take anywhere from a few days to several weeks for Google to discover, crawl, and rank a brand-new link.
The more links you build and the more traffic your repo receives, the faster Google is likely to index it.
By following these steps, you will optimize your repo for discoverability and increase its chances of appearing in relevant Google searches.





