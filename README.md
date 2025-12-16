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
    } 
    depends_on = [aws_security_group.allow_tls]
    count = 3
    for_each = toset(["dev", "prod", "staging"])
    provider = "aws.dev"
}
```
### How to use 

























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





