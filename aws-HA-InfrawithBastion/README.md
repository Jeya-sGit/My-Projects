# 🚀 AWS High-Availability Web Infrastructure (via Terraform & Jenkins)

## 📖 Introduction

This project automates the deployment of a **highly available, fault-tolerant, and secure** web infrastructure in the AWS `ap-south-1` (Mumbai) region. By leveraging **Infrastructure as Code (IaC)** with Terraform, the environment is provisioned with zero manual intervention. The architecture is designed to host a web application that can survive the failure of an entire AWS Availability Zone.

## 🏗️ Core Infrastructure Components

### **1. Networking (The Foundation)**

* **Custom VPC:** A dedicated Virtual Private Cloud with a `10.0.0.0/16` CIDR block.
* **Multi-AZ Subnets:** * **2 Public Subnets:** For external-facing resources (ALB, Bastion).
* **2 Private Subnets:** For secure application hosting (Web Servers).


* **Gateways:**
* **Internet Gateway (IGW):** Enables communication between the VPC and the internet.
* **NAT Gateway:** Resides in the public subnet to allow private instances to fetch updates without being exposed to the internet.


### **2. Compute & Scaling**

* **Auto Scaling Group (ASG):** Automatically manages the lifecycle of EC2 instances.
* **Desired Capacity:** 2 Instances.
* **Max Capacity:** 3 Instances.


* **Launch Template:** Defines the Amazon Linux 2 AMI, instance type (`t2.micro`), and a **User Data script** that automatically installs Apache (`httpd`) and deploys a custom web page.

### **3. Load Balancing**

* **Application Load Balancer (ALB):** A Layer 7 load balancer that distributes incoming traffic across the healthy instances in the private subnets.
* **Target Groups:** Performs continuous health checks to ensure traffic is only sent to "Healthy" instances.

## 🔐 Security & Access Management

### **1. The Bastion Host (Jump Box)**

To keep the environment secure, the web servers are hidden in private subnets. Access is managed through a **Bastion Host** in the public subnet.

* **Flow:** Developer  Bastion (Public IP)  Private Server (Private IP).

### **2. Security Groups (Multi-Layer Firewall)**

| Security Group | Traffic Allowed | Port | Source |
| --- | --- | --- | --- |
| **ALB-SG** | HTTP | 80 | 0.0.0.0/0 (Anywhere) |
| **Bastion-SG** | SSH | 22 | Developer IP |
| **EC2-SG** | HTTP / SSH | 80 / 22 | ALB-SG / Bastion-SG |

### **3. Key Management**

* **Terraform TLS Provider:** Automatically generates an RSA Private Key.
* **Local File:** Saves the `AWS-HA-App-key.pem` to your local machine for immediate use.

## ⚙️ Automation & CI/CD

### **Jenkins Pipeline**

The project is deployed via a **Jenkinsfile** that manages the lifecycle of the infrastructure through parameters:

* **Init:** Configures the S3 Backend and DynamoDB state locking.
* **Plan:** Validates the **29 resources** to be added.
* **Apply:** Provisions the live environment.
* **Destroy:** Tunnels a clean teardown of all resources to avoid costs.

## 🛠️ How to Connect

1. **Web Application:** Use the `alb_dns_endpoint` output from the Terraform logs.
2. **SSH Access:**
```bash
# Connect to the Bastion
ssh -i AWS-HA-App-key.pem ec2-user@<Bastion_Public_IP>

```
## 📊 Summary of Resources

* **Total Resources:** 29
* **Region:** ap-south-1
* **State Management:** Remote (S3 + DynamoDB)