# 01 Jan 2026 Terraform Cheatsheet
> **Commands, Codes & Steps for the Terraform Associate & Advanced Usage**

![Terraform](https://img.shields.io/badge/terraform-%23623CE4.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Status](https://img.shields.io/badge/Status-Maintained-green?style=for-the-badge)

A comprehensive guide covering Terraform advanced file structures, CLI commands, HCL syntax, state management, and exam preparation notes.

---

## 📚 Table of Contents
1. [Section 1: Basic Commands & Settings](#section-1-basic-commands--settings)
2. [Section 2: Variables & Data Types](#section-2-variables--data-types)
3. [Section 3: Logic, Functions & Locals](#section-3-logic-functions--locals)
4. [Section 4: Data Sources & Debugging](#section-4-data-sources--debugging)
5. [Section 5: Provisioners & Modules](#section-5-provisioners--modules)
6. [Section 6: Workspaces & State Basics](#section-6-workspaces--state-basics)
7. [Section 7: Remote State Management](#section-7-remote-state-management)
8. [Section 8: Security Primer](#section-8-security-primer)
9. [Section 9: HCP Cloud & Enterprise](#section-9-hcp-cloud--enterprise)
10. [Section 10: Terraform Challenges](#section-10-terraform-challenges)
11. [Section 11: Exam Prep Notes](#section-11-terraform-associate-exam)

---
## Section 1: Basic Commands & Settings

### Initialization & Lifecycle
```
terraform init          # Initialize directory
terraform init -upgrade # Upgrade modules/plugins

terraform fmt           # Format code
terraform validate      # Check for syntax errors

terraform plan          # Preview changes
terraform plan -out ec2.plan   # Save plan
terraform show -json ec2.plan | jq # View plan as JSON

terraform apply         # Apply changes
terraform apply ec2.plan # Apply saved plan

# terraform destroy     # Destroy resources   
```

> [!NOTE] Terraform loads all configuration files in a directory as a single unit.

### For plan
terraform plan -var-file="dev.tfvars"

### terraform settings 
```
terraform {
    required_version = ">= 1.14"
}
```

### Targeting Resources

Avoids API throttling or isolates changes.
```
terraform plan -target=aws_instance.ec2 
terraform apply -target=aws_instance.ec2 
terraform destroy -target=aws_instance.ec2 
```

---

## Section 2: Variables & Data Types

### Variable Definition Precedence

Terraform loads variables in this order (last one wins):

1. Environment variables (`TF_VAR_name`)
2. `terraform.tfvars`
3. `terraform.tfvars.json`
4. `*.auto.tfvars` or `*.auto.tfvars.json`
5. `-var` and `-var-file` CLI options

usage
1. terraform plan -var-file="dev.tfvars"
### Complex Data Types

```
variable "mylist" {
    type    = list(number)
    default = [1, 2, 3]
}

variable "mymap" {
    type    = map(string)
    default = {"one" = "1", "two" = "2"}
}

variable "myset" {
    type    = set(string) # Unique values only
    default = ["one", "two", "three"]
}

variable "mytuple" {
    type    = tuple([string, number])
    default = ["one", 2]
}
```

**Accessing Values:**
Terraform
```
instance_type = var.mylist[2]
instance_type = var.mymap["us-east-1"] 
```
when using count use dynamic names with count index

---

## Section 3: Logic, Functions & Locals

### Count & Splat Expressions usage
Terraform

```
resource "aws_instance" "ec2" {
    count = 3
    tags = {
        Name    = "ec2-${count.index}"
        project = var.project[count.index]
    }
}

# Splat expression [*]
output "arns" {
    value = aws_instance.ec2[*].arn
}
```

### Conditional Expressions
Terraform
```
resource "aws_instance" "ec2" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = var.env == "dev" ? "t2.micro" : "t2.small"
}
```

### Locals
Locals are private to the module and allow dynamic logic.
Terraform

```
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
```

### Built-in Functions Console
```
terraform console
> length(var.project)
> max(var.project)
> file("path/to/file")
> zipmap(["a", "b"], [1, 2]) # Output: {"a"=1, "b"=2}
> fileset("path/to/directory", "*.txt")
```

---

## Section 4: Data Sources & Debugging

### Data Sources
Fetching data from AWS dynamically.
Terraform
```
data "aws_ami" "my_image" {
    most_recent = true
    owners      = ["amazon"]
    filter {
        name   = "name"
        values = ["al2023-ami-ecs-hvm*"]
    }
}
```

### Dynamic Blocks
Cleanly handle repeated nested blocks (like ingress rules).
Terraform
```
variable "sg_ports" {
    type = list(number)
    default = [80, 443, 22]
}

resource "aws_security_group" "dynamicsg" {
    name = "dynamic-sg"
    dynamic "ingress" {
        for_each = var.sg_ports
        iterator = port
        content {
            from_port   = port.value
            to_port     = port.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}
```

### Debugging
**Log Levels:** `DEBUG`, `TRACE`, `INFO`, `WARN`, `ERROR`
Bash
```
export TF_LOG="TRACE"
export TF_LOG_PATH="./terraform.log"
```

> [!NOTE]  **Common Errors:** Language, State, Core, Provider errors.

---

## Section 5: Provisioners & Modules
### Provisioners
> [!WARNING]
> 
> Use only as a last resort.


```
resource "aws_instance" "ec2" {
    # ... config ...
    
    provisioner "remote-exec" {
        inline = ["echo 'Hello' > index.html"]
        when   = "create"
    }

    provisioner "local-exec" {
        command    = "echo ${self.public_ip} >> server_ip.txt"
        when       = "destroy"
        on_failure = "continue"
    }
}
```

### Modules
**Standard Structure:**
Plaintext

```
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
```

**Usage:**
Terraform
```
module "ec2" {
    source = "./modules/ec2"
    ami    = "ami-0c55b159cbfafe1f0"
}
# Accessing module output
resource "aws_eip" "lb" {
    instance = module.ec2.instance_id
}
```

**Publishing Requirements:** GitHub Public Repo, Format `terraform-<Provider>-<Name>`, Semantic Versioning tags (v1.0.4), Standard module structure, the GitHub repository description is used to populate the short description of the module.
**Basics of standard Module Structure:** diffrent modules for diffrent resources ex: Network, Web, App, Database, Routing, Security, Storage, etc.

---
## Section 6: Workspaces & State Basics
### Workspaces
Manage different environments (dev, prod) with the same code.
```
terraform workspace new dev
terraform workspace select dev
terraform workspace list
terraform workspace show
```

**Workspace Interpolation:**
Terraform
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

### Basic State Commands

```
terraform state rm aws_instance.ec2          # remove the resource from state
terraform state show aws_instance.ec2        # show the resource from state
terraform state mv aws_instance.ec2 new_name # Rename
terraform state list                         # list the resources in state
terraform state pull                         # pull the state from s3
terraform state push                         # push the state to s3
terraform apply -replace="aws_instance.ec2"  # destroys and recreate the resource
terraform state replace aws_instance.ec2     # to replace aws_instance.ec2
```

### Terraform Graph

```
terraform graph | dot -Tsvg > graph.svg
terraform graph -draw-cycles                # use graphviz locally  to visualize the graph 
```

---
## Section 7: Remote State Management

> [!IMPORTANT]
> 
> Always use Git for code (with .gitignore) and S3/Remote Backend for state.

### S3 Backend Configuration

Terraform
```
terraform {
  backend "s3" {
    bucket         = "eeswar-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
    dynamodb_table = "eeswar-terraform-lock"
    profile        = "eeswar"
  }
}
```

### State Locking
Prevents concurrent operations. Terraform uses DynamoDB for locking with S3.

```
resource "time_sleep" "wait_100_seconds" {
    create_duration = "100s"
}

```
- **Force Unlock:** `terraform force-unlock <lock-id>` (Use with extreme caution).

### Remote State Data Source

Read outputs from another Terraform project's state file.
Terraform
```
data "terraform_remote_state" "eip" {
    backend = "s3"
    config = {
        bucket = "eeswar-terraform-state"
        key    = "terraform.tfstate"
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

---

## Section 8: Security Primer

### Sensitive Variables
Terraform

```
variable "password" {
    type      = string
    sensitive = true
}

output "password" {
    value     = var.password
    sensitive = true
}
```
> [!NOTE] for sensitive variables terraform will throw error if use it in outputs if you want to use it in outputs use 
### HashiCorp Vault

Dynamic secrets engine.
Terraform

```
provider "vault" {
    address = "[http://127.0.0.1:8200](http://127.0.0.1:8200)"
    token   = "my-token"
}
```

### Multiple Providers (Aliases)
Terraform

```
provider "aws" {
    alias  = "dev"
    region = "us-east-1"
}
provider "aws" {
    alias  = "prod"
    region = "us-east-2"
}

resource "aws_instance" "ec2" {
    provider = aws.dev
    # ...
}
```


### Terraform spalat expression allows us to get a list of all attributes
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


### Terraform output
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



### How to use terraform import
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


---
## Section 9: HCP Cloud & Enterprise

**Key Features:**
- **Organizations & Teams:** Governance structure.
- **Workspaces:** VCS-driven, CLI-driven, or API-driven workflows.
- **Sentinel:** Policy as Code (checks run _before_ apply).
- **Private Registry:** Private storage for modules like aws ecr.
- **Air Gap:** For strict security environments (no internet).
- https://www.hashicorp.com/en/pricing?tab=terraform
- 

---

## Section 10: Terraform Challenges

### Challenge 1: Create AWS IP, you can modify your code as you like 
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

<details>

<summary><b>Click to view Solution</b></summary>

Terraform

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

</details>

### Challenge 2: Security Group Optimization, and resource should be created
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

<details>

<summary><b>Click to view Solution</b></summary>

Terraform

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

</details>

###  Challenge 3: For_Each Map, if map values are removed , ec2 instance should 
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

<details>

<summary><b>Click to view Solution</b></summary>

Terraform

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

</details>

### Challenge 4:  
```
.gitkeep file
1. Clients wants a code that can create IAM user in AWS account with following
syntax:
admin-user-{account-number-of-aws}
2. Client wants to have a logic that will show names of ALL users in AWS account in the output.
3. Along with list of users in AWS, client also wants Terraform to show Total number of users in AWS.

```


<details>

<summary><b>Click to view Solution</b></summary>

Terraform

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

</details>

---
## Section 11: Terraform Associate Exam

### 📋 Exam Requirements

1. **ID:** Physical Government ID required, recommended to have 2 another ids with larger text of name
2. **Environment:** Clear desk, no electronics, no noise, adequate lighting.
3. **Prohibitions:** No phones, smartwatches, or other people in the room.
4. 3. check your system compatability in chrome for exam 
5. pyhysical space 
      Room Requirements
    No one else is permitted to be in your testing room for the duration of your exam.
    Be sure your space is adequately lit, so the proctor can see you and your space.
    Your desk and work area must be clear.
    Any electronics in the room must not be operational.
    Background noise must be as limited as possible.
    No phones, smartwatches, or other similar devices are allowed in the room.
    ***can be called same as aws exam***
6. Make sure there are no notification that appear on your screen while giving the exams.
7. Always verify the updated guidelines released by HashiCorp for the exams to ensure you get the latest update before sitting for the exams.
8. https://hashicorp-certifications.zendesk.com/hc/en-us/articles/26234761626125-Exam-appointment-rules-and-requirements



### 📝 Quick Review Notes

- **Provider Block:** Not mandatory.
- **Version Constraints:** `required_version = ">= 1.0"` locks Terraform core version.
- **Refresh:** Deprecated; `terraform apply` refreshes state automatically.
- **Functions:** User-defined functions are **not** supported.
- **Implicit vs Explicit Dependency:**
    - _Implicit:_ `id = aws_instance.web.id`
    - _Explicit:_ `depends_on = [aws_s3_bucket.b]`
- **Meta Arguments:** `depends_on`, `count`, `for_each`, `lifecycle`.

### Function Cheat Sheet

|**Category**|**Functions**|
|---|---|
|**Numeric**|`abs`, `ceil`, `floor`, `max`, `min`|
|**String**|`concat`, `replace`, `split`, `join`, `tolower`, `toupper`|
|**Collection**|`element`, `keys`, `length`, `merge`, `sort`, `slice`|
|**Filesystem**|`file`, `filebase64`, `dirname`|

```
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
33. depends_on   description: used for explicit dependency
34. count description: used for creating multiple resources
35. for_each description: used for creating multiple resources
36. provider  desc: used for specifying provider
37. lifecycle desc: used for managing resource lifecycle
     1. create_before_destroy  desc: used for creating resource before destroying
     2. prevent_destroy desc: used for preventing resource deletion
     3. ignore_changes desc: used for ignoring changes
     4. replace_triggered_by desc: used for replacing resource 
38. sectinal checks : runs before plan
39. terraform graph : visual representation of resources note dot format
40. terraform tvfars : used for variables declaration > variables.tf > terraform.tfvars or dev.tfvars
41. order variable defaults < *.tfcars < env variables < CLI variables   :::: env example export TF_VAR_vpn_ip="101.30.13.03/32"  in linux
42. precedence -var in cli overerides *.auto.tfvars or *.auto.tfvars.json overerides terraform.tfvars.json overrides terraform.tfvars overerides env variables
43. use outputs to store data about resource in state file
44. terraform console : used for interactive mode
45. dependency lock file : used for locking the version of the provider
46. implecent vs explicit dependency : **Implicit** dependencies are created **automatically** when resources share data (referencing an ID), while **Explicit** dependencies are created **manually** using `depends_on` to force a specific order.
47. features of Terraform enterprise plan
    1. sso
    2. auditing 
    3. private data center networking
    4. clustering
    5. Team & Governance feature are not available in terraform cloud free tier
    6. explore more on https://www.hashicorp.com/en/pricing?tab=terraform 
48. HCP Hashicorp cloud platform , it also has private module registry
49. encryption of state file is also available in saas of hcp
50. Hcp workspace linked to version controlled repository(single branch)  then it runs auto on source code changes
51. terraform apply -replace="aws_instance.ec2" : used for replacing resource
52. Benefits of terraform iac 
    1. Automation
    2. Version control
    3. Reusability
53. modules of git registry : uses default branch u can also override it : git::https://github.com/terraform-aws-modules/vpc.git?ref=tags/v3.11.0
54. splat expressions : used for accessing multiple values from a list or map : aws_instance.ec2[*].id
55. list usage : var.list_of_values[0]
56. map usage : var.map_of_values["key"]
57. Large Infra: Break the infrastructure into separate state files (splitting the state) to prevent API rate limiting and reduce blast radius.
58. backend : used for storing state file in remote storage :  migrate backend option is there
59. Air Gapped environemnet isolation : isolates physical hardware from internet
60. requirements for publishing Module in registry : 
	1. Github, 
	2. Named terraform-<Provider>-<Module Name> 
	   3. Repo desc, 
	   4. Standard Module structure 
	   5. x.y.z tags for releases
61. disadvantage of dynamic block : hard to read & maintain
62. api & cli access for terraform is through tokens
63. terrafomr uses parallelism to speed up the execution
64. terraform providers can be installed through airgapped systems
65. terraform & terrafomr provider doesnt need major version compatability
66. ! sensitive values are visible in state file 
67. during state lock : plan, destroy, apply, refresh, and other state commands are blocked
68. go through terraform .gitignore file for more info
69. terraform force-unlock <lock-id> : used for unlocking state file
70. Data Type of Object & Multiple Provider Configuration in Modules are important for exam
71. make use of Data Source for dynamic ami_id
72. output values are defined in the Child and Root modules: When you run terraform apply it shows output values of root module without explicit call to teh child module.
73. if variable typr is string and value is number then it converts to string automatically
74. to migrate the Terraform state file from localhost to S3 bucket you need terraform init command not any other
75. Terraform will not store the default value of the variable and its description in the Terraform state file


```




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


