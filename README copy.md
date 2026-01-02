# 01 Jan 2026 Terraform Cheatsheet
> **Commands, Codes & Steps for the Terraform Associate & Advanced Usage**

![Terraform](https://img.shields.io/badge/terraform-%23623CE4.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Status](https://img.shields.io/badge/Status-Maintained-green?style=for-the-badge)

A comprehensive guide covering Terraform advanced file structures, CLI commands, HCL syntax, state management, and exam preparation notes.

---

## 📚 Table of Contents
- [Basic Commands](#basic-commands)
- [Variables & Data Types](#variables--data-types)
- [Functions & Expressions](#functions--expressions)
- [State Management](#section-7-remote-state-management)
- [Security Primer](#section-8-security-primer)
- [HCP & Enterprise](#section-9-hcp-hashicorp-cloud-platform-cloud--enterprise)
- [Challenges & Solutions](#section-10-terraform-challenges)
- [Exam Prep Notes](#section-11-terraform-associate-exam)

---

## 🛠 Basic Commands

### Initialization & Validation
```
terraform init
# OR upgrade modules/plugins
terraform init -upgrade

terraform fmt          # Format code
terraform validate     # Check for syntax errors
```
CSDSC

### Plan & Apply
```
terraform plan
# OR save the plan to a file
terraform plan -out ec2.plan

# View the plan in JSON format using jq
terraform show -json ec2.plan | jq

terraform apply
# OR apply a saved plan
terraform apply ec2.plan
```
### Destroy
```
terraform destroy
# OR target specific resources
terraform destroy -target=aws_instance.ec2
```

> [!NOTE] Terraform loads all configuration files in a directory as a single unit.

### Debugging & Troubleshooting

**Log Levels:** `DEBUG`, `TRACE`, `INFO`, `WARN`, `ERROR`
```
export TF_LOG="TRACE"
export TF_LOG_PATH="./terraform.log"
```

**Common Error Categories:**

1. Language error    
2. State error
3. Core errors
4. Provider errors

---

## 📦 Variables & Data Types

### Variable Definition Precedence

Terraform loads variables in the following order (last one wins):

1. Environment variables
    
2. `terraform.tfvars` file
    
3. `terraform.tfvars.json` file
    
4. `*.auto.tfvars` or `*.auto.tfvars.json`
    
5. `-var` and `-var-file` CLI options
    

### Complex Data Types (HCL)

Terraform

```
variable "mylist" {
    type    = list(number)
    default = [1, 2, 3]
}

variable "mymap" {
    type    = map(string)
    default = {"one" = "1", "two" = "2", "three" = "3"}
}

variable "myset" {
    type    = set(string)
    default = ["one", "two", "three"]
}

variable "mytuple" {
    type    = tuple([string, number, bool])
    default = ["one", 2, true]
}
```

**Accessing Values:**

Terraform

```
instance_type = var.mylist[2]
instance_type = var.mymap["us-east-1"] # key value pair
```

---

## 🧮 Functions & Expressions

### Count & Dynamic Naming

Terraform

```
resource "aws_instance" "ec2" {
    count = 3
    tags = {
        Name    = "ec2-${count.index}"
        project = var.project[count.index]
    }
}
```

### Conditional Expression (Ternary)

Terraform

```
resource "aws_instance" "ec2" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = var.env == "dev" ? "t2.micro" : "t2.small"
}
```

### Splat Expressions `[*]`

Allows you to get a list of all attributes.

Terraform

```
output "arns" {
    value = aws_iam_user.user[*].arn
}
```

### Dynamic Blocks

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

### Built-in Functions Console

Bash

```
terraform console
> length(var.project)
> max(var.project)
> file("path/to/file")
> zipmap(["a", "b", "c"], [1, 2, 3])
```

---

## Section 7: Remote State Management

> [!IMPORTANT]
> 
> Always use Git for code collaboration (with .gitignore) and S3/Remote Backend for state storage to avoid data leaks and conflicts.

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

### State Commands

Bash

```
terraform state list                    # List all resources
terraform state pull                    # Pull state from S3
terraform state rm aws_instance.ec2     # Stop managing a resource
terraform state mv aws_instance.ec2 new # Rename/Move
terraform state show aws_instance.ec2   # Show details
```

### Remote State Data Source

Fetching outputs from another state file:

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

### HashiCorp Vault Integration

Terraform

```
provider "vault" {
    address = "[http://127.0.0.1:8200](http://127.0.0.1:8200)"
    token   = "my-token"
}

data "vault_generic_secret" "password" {
    path = "secret/data/my-secret"
}
```

---

## Section 9: HCP (HashiCorp Cloud Platform) Cloud & Enterprise

**Key Features:**

- **Organizations:** Manage multiple teams.
    
- **Workspaces:**
    
    1. Version Control Workflow
        
    2. CLI-driven Workflow
        
    3. API-driven Workflow
        
- **Sentinel (Policy as Code):** Similar to AWS SCPs.
    
- **Private Registry:** Like AWS ECR but for Terraform modules.
    
- **Air Gap:** Ensures data is only accessed locally/securely.
    

---

## Section 10: Terraform Challenges

Use the "Trial and Error" method to solve these.

### Challenge 1: Create AWS IP

<details>

<summary><b>Click to view Solution</b></summary>

Terraform

```
provider "aws" {
  version    = "~> 2.54"
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

resource "aws_eip" "eeswar_app_ip" {
  vpc = true
}
```

</details>

### Challenge 2: Best Practices & Optimization

<details>

<summary><b>Click to view Solution</b></summary>

Terraform

```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "splunk" {
  default = "8088"
}

resource "aws_security_group" "payment_app" {
  name        = "payment_app"
  description = "Application Security Group"
  depends_on  = [aws_eip.example]

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
  
  # ... (other ingress rules)

  egress {
    from_port   = var.splunk
    to_port     = var.splunk
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "example" {
   domain = "vpc"
}
```

</details>

### Challenge 3: Map-based Creation

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
    tags = {
        Name = each.key
    }
}
```

</details>

---

## Section 11: Terraform Associate Exam

### 📋 Exam Requirements

1. **ID:** Physical Government ID required.
    
2. **Environment:** Clear desk, no electronics, no noise, adequate lighting.
    
3. **No Phones:** Strictly prohibited.
    
4. **System:** Check compatibility (Chrome).
    

### 📝 Quick Review Notes

- **Provider Block:** Not mandatory.
    
- **Init -upgrade:** Used to upgrade versions within constraints.
    
- **FMT:** `terraform fmt -recursive` formats subdirectories.
    
- **Refresh:** Deprecated and unsafe.
    
- **Functions:** User-defined functions are **not** supported.
    
- **Workspace:** Used for managing multiple environments (dev, prod).
    
- **Modules:** `module.module_name.output_name` to access outputs.
    

### Function Cheat Sheet

|**Category**|**Functions**|
|---|---|
|**Numeric**|`abs`, `ceil`, `floor`, `max`, `min`|
|**String**|`concat`, `replace`, `split`, `join`, `tolower`, `toupper`|
|**Collection**|`element`, `keys`, `length`, `merge`, `sort`, `slice`|
|**Filesystem**|`file`, `filebase64`, `dirname`|

**Common Function Examples:**

|**Function**|**Example Input**|**Output**|
|---|---|---|
|**lookup**|`lookup({a="red", b="blue"}, "a")`|`"red"`|
|**zipmap**|`zipmap(["a", "b"], [1, 2])`|`{a=1, b=2}`|
|**element**|`element(["a", "b"], 0)`|`"a"`|
|**file**|`file("/path/to/file")`|`"file contents"`|
|**merge**|`merge({a=1}, {b=2})`|`{a=1, b=2}`|

### Important Concepts for Exam

- **Implicit vs Explicit Dependency:**
    
    - _Implicit:_ Created automatically via referencing (e.g., `instance_id = aws_instance.web.id`).
        
    - _Explicit:_ Manually created using `depends_on`.
        
- **Meta Arguments:** `depends_on`, `count`, `for_each`, `lifecycle`.
    
- **Sentinel:** Checks run **before** the plan.
    
- **State Locking:** Prevents corruptions. Commands like plan, apply, destroy are blocked during lock.
    
- **Force Unlock:** `terraform force-unlock <lock-id>` (Use with caution).
    

---

### Additional Resources

- [Terraform Registry](https://registry.terraform.io/)
    
- [Terraform Beginner to Advanced (GitHub)](https://github.com/zealvora/terraform-beginner-to-advanced-resource)
    

> **How to choose an IaC Tool?**
> 
> 1. Is your infrastructure vendor-specific (e.g., AWS only)?
>     
> 2. Are you planning Multi-cloud/Hybrid?
>     
> 3. Integration with Config Management (Ansible)?
>     
> 4. Price and Support?
>