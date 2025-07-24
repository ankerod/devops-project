# DevOps Project

In this project I will use base stack for DevOps Engineer. <br>

I use technologies such as:
1. Git
2. Docker
3. Terraform

I will gradually describe all steps wich I will do.

## 📄 Feature 1. Creation a simple front-end page
I will not create my own page. Instead this, I will take ReactJS app from open-source [GitHub repository](https://github.com/issaafalkattan/React-Landing-Page-Template.git).

### Step 1. Clone repository
``` bash
git clone https://github.com/issaafalkattan/React-Landing-Page-Template.git react-web-page
```

---

### Step 2. Delete all git/github files
``` bash
cd react-web-page
```

``` bash
rm -rf .git .github
```

## 🛠️ Feature 2. Configure Nginx
In order to web server with ReactJS works correctly, you need configure nginx.conf file, which locate in root ReactJS directory.

#### nginx.conf

``` conf
working_processes 1;

events {
    worker_connection 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;

    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;

            index index.html index.htm;

            try_files $uri $uri/ /index.html;
        }
    }
}
```
## 🐳 Feature 3. Configure Dockerfile and deploy it

If you want to easy deploy your app on server, you must be use containerization, for example Docker.

### Step 1. Downoload Docker desktop
First, you must downoload [Docker desktop](https://www.docker.com/products/docker-desktop/) on your computer. After downoloading you will have Docker and Docker Engine on your computer for easy work.

---

### Step 2. Create and configure Dockerfile
You must create Dockerfile in root directory of your app.

#### Dockerfile

``` Dockerfile
FROM node:24-bullseye-slim as builder

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build

FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

COPY nginx.conf /etc.nginx/conf.d/default.conf

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]
```

---

### Step 3. Build Docker image

``` bash
docker build -t react-js-app .
```

You can also check your images:
`docker images` or `docker image list`

---

### Step 4. Run Docker container

``` bash
docker run -d -p 80:80 --name react-js-app react-js-app
```

You can also check your conatainers:
`docker ps` for working container or `docker ps -a` for all containers.

After the steps above, your container must run on `localhost:80`

## 🌎 Feature 4. Configure Terraform

If you want to easy setup your cloud infrastructure, you can use Terraform (IaC principles).

### Step 1. Install Terraform 

### `Macos`

``` bash
brew tap hashicorp/tap
```

``` bash
brew tap hashicorp/tap
```

### `Windows`

``` bash
choco install terraform
```

### `Linux`

``` bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```

``` bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

``` bash
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

``` bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

``` bash
sudo apt update
```

``` bash
sudo apt-get install terraform
```

---

### Step 2. Create SSH key-pair
First, you must create SSH key-pair for secure connect to your instance.

``` bash
ssh-keygen
```

After this, created key, will be saved to `~/.ssh` folder
#### `⚠️ Caution!!!` your created key (not .pub extension) must be on safety!

### Step 3. Create varibles.tf
For easy access with `main.tf` you need define varibles.

### `variables.tf`

``` bash
variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "DevOps-Project"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-0af9b40b1a16fe700"
}

variable "ssh_key_name" {
  type    = string
  default = "id_ed25519"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type    = string
  default = "10.0.10.0/24"
}
```

---

### Step 4. Configure terraform.tf
This is main Terraform file.

### `main.tf`

``` t
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_key_pair" "deployer_key" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/id_ed25519.pub") # Instead this, indicate your key-pair
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = "${var.region}a"

  tags = {
    Name    = "${var.project_name}-subnet-pb"
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # All trafic
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-rt"
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id
  name   = "${var.project_name}-web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-web-sg"
    Project = var.project_name
  }
}

resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.deployer_key.key_name

  tags = {
    Name    = "${var.project_name}-instance"
    Project = var.project_name
  }
}
```

---

### Step 5. Create outputs.tf

This file define which text will be show in terminal after susscesfully apply `main.tf`.

### `outputs.tf`

``` t
output "public_ip_instance" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP adress of the main EC2 instance."
}

output "ssh_command" {
  description = "Command for SSH connect to EC2 instance."
  value       = "ssh -i ~/.ssh/${var.ssh_key_name} ec2-user@${aws_instance.web_server.public_ip}"
  sensitive   = false
}
```

Step 6. Run terraform

``` bash
terraform fmt
```

``` bash
terraform init
```

``` bash
terraform plan
```

``` bash
terraform apply
```

Use `terraform destroy` to destroy cloud infrastructure.

## Feature 5. Configure Ansible
If you want to create you cloud infrastructure easy to maintain, you need to use Ansible in a pair with Terraform.

### Step 1. Install Ansible

#### `Prerequisities.` Must be installed Python in your device.

``` bash 
python3 -m pip install --user ansible
```

### Step 2. Create Docker variables.
To demonstrate how Ansible work I will install Docker on my EC2 instance.

#### `Ansible directory`

``` ansible
ansible/
    ├── roles/
    │   └── docker/
    │       ├── tasks/
    │       │   └── main.yml
    │       └── vars/
    │           └── main.yml  <--- Create this file.
    └── playbook.yml
```

### `vars/main.yml`

```
---
docker_user: "ec2-user"
```


### Step 3. Create Docker role.

#### `Ansible directory`

```
ansible/
    ├── roles/
    │   └── docker/
    │       ├── tasks/
    │       │   └── main.yml <--- Create this file.
    │       └── vars/
    │           └── main.yml
    └── playbook.yml
```

### `tasks/main.yml`

``` ansible
---
- name: Update apt cache
  ansible.builtin.apt:
    update_cache: true

- name: Install Docker
  community.general.snap:
    name: docker
    state: present
    classic: true

- name: Update apt after installing Docker
  ansible.builtin.apt:
    update_cache: true
```

### Step 3. Create Ansible playbook
Now, that connect all our roles I create `playbook.yml` (main Ansible file).

### `playbook.yml`

```
- name: DevOps Project
  hosts: all
  become: true

  roles:
    - docker
```

### Step 4. Configure `inventory_template`.
This file neef to create inventory.ini (this file define public IP of our servers).

### `inventory_template.tpl`

```
[web_servers]
${instance_ip} ansible_user=ec2-user ansible_ssh_private_key=${ssh_private_key_path}
```

### Step 5. Update `main.tf`
In the end of `main.rf` add this code:
```
  resource "local_file" "ansible_inventory" {
    content  = templatefile("${path.module}/ansible/inventory.tpl", {
      instance_ip = aws_instance.web_server.public_ip
      ssh_private_key_path = var.ssh_private_key_path
    })
    filename = "inventory.ini"
  }
```

### Step 6. Run Terraform

``` bash
terraform apply
```

### Step 7. Run Ansible

``` bash
ansible-playbook -i aws-terraform/inventory.ini ansible/playbook.yml -b
```
