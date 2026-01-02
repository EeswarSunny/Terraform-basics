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
```bash
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

> [!NOTE]
> 
> Terraform loads all configuration files in a directory as a single unit.

### Terraform Settings Block

Terraform

```
terraform {
    required_version = ">= 1.14"
}
```

### Targeting Resources

Avoids API throttling or isolates changes.

Bash

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
    

### Complex Data Types

Terraform

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

---

## Section 3: Logic, Functions & Locals

### Count & Splat Expressions

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
```

### Built-in Functions Console

Bash

```
terraform console
> length(var.project)
> max(var.project)
> file("path/to/file")
> zipmap(["a", "b"], [1, 2]) # Output: {"a"=1, "b"=2}
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

**Common Errors:** Language, State, Core, Provider errors.

---

## Section 5: Provisioners & Modules

### Provisioners

> [!WARNING]
> 
> Use only as a last resort.

Terraform

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
minimal-module/
├── README.md
├── main.tf
├── variables.tf
└── outputs.tf
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

**Publishing Requirements:** GitHub Public Repo, Format `terraform-<Provider>-<Name>`, Semantic Versioning tags (v1.0.4).

---

## Section 6: Workspaces & State Basics

### Workspaces

Manage different environments (dev, prod) with the same code.

Bash

```
terraform workspace new dev
terraform workspace select dev
terraform workspace list
terraform workspace show
```

**Workspace Interpolation:**

Terraform

```
instance_type = local.instance_type[terraform.workspace]
```

### Basic State Commands

Bash

```
terraform state list
terraform state show aws_instance.ec2
terraform state rm aws_instance.ec2        # Stop tracking
terraform state mv aws_instance.ec2 new_name # Rename
terraform apply -replace="aws_instance.ec2"  # Force recreate
```

### Terraform Graph

Bash

```
terraform graph | dot -Tsvg > graph.svg
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

---

## Section 9: HCP Cloud & Enterprise

**Key Features:**

- **Organizations & Teams:** Governance structure.
    
- **Workspaces:** VCS-driven, CLI-driven, or API-driven workflows.
    
- **Sentinel:** Policy as Code (checks run _before_ apply).
    
- **Private Registry:** Private storage for modules.
    
- **Air Gap:** For strict security environments (no internet).
    

---

## Section 10: Terraform Challenges

### Challenge 1: Create AWS IP

<details>

<summary><b>Click to view Solution</b></summary>

Terraform

```
provider "aws" {
  version    = "~> 2.54"
  region     = "us-east-1"
}

resource "aws_eip" "eeswar_app_ip" {
  vpc = true
}
```

</details>

### Challenge 2: Security Group Optimization

<details>

<summary><b>Click to view Solution</b></summary>

Terraform

```
variable "splunk" { default = "8088" }

resource "aws_security_group" "payment_app" {
  name        = "payment_app"
  depends_on  = [aws_eip.example]

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
  
  egress {
    from_port   = var.splunk
    to_port     = var.splunk
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

</details>

### Challenge 3: For_Each Map

<details>

<summary><b>Click to view Solution</b></summary>

Terraform

```
variable "instance_config" {
  type = map
  default = {
    instance1 = { instance_type = "t2.micro", ami = "ami-03a6eaae9938c858c" }
    instance2 = { instance_type = "t2.small", ami = "ami-053b0d53c279acc90" }
  }
}

resource "aws_instance" "example" {
    for_each      = var.instance_config
    ami           = each.value.ami
    instance_type = each.value.instance_type
    tags          = { Name = each.key }
}
```

</details>

---

## Section 11: Terraform Associate Exam

### 📋 Exam Requirements

1. **ID:** Physical Government ID required.
    
2. **Environment:** Clear desk, no electronics, no noise, adequate lighting.
    
3. **Prohibitions:** No phones, smartwatches, or other people in the room.
    

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

**Common Examples:**

- `lookup({a="red"}, "a")` -> `"red"`
    
- `zipmap(["a", "b"], [1, 2])` -> `{a=1, b=2}`
    
- `element(["a", "b"], 0)` -> `"a"`
    
- `merge({a=1}, {b=2})` -> `{a=1, b=2}`
    

> **How to choose an IaC Tool?**
> 
> 1. Vendor lock-in risk? (Terraform supports multi-cloud)
>     
> 2. Integration with Config Management (Ansible)?
>     
> 3. Cost & Community Support?
>