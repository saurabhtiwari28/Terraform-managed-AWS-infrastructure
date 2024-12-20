# Terraform-managed-AWS-infrastructure 
![Terraform with AWS](https://github.com/user-attachments/assets/df4199f5-726f-475c-864b-01a2dd7e5114)
This project demonstrates the use of Terraform to provision and manage AWS infrastructure components. The infrastructure includes EC2 instances, a VPC, a Load Balancer, and an S3 bucket. Additionally, user data scripts are used to configure the EC2 instances during launch.

# Terraform Configuration: 
The main.tf file contains the complete configuration for AWS resources.
Variables and providers are defined in variables.tf and provider.tf.

# Resources Created:

1. Virtual Private Cloud (VPC): 
   A custom VPC is created to host other AWS resources.

2. EC2 Instances: Two EC2 instances (web1 and web2) are provisioned in separate subnets for redundancy.

3. Load Balancer: An application load balancer (ALB) is configured to distribute traffic between the EC2 instances.

4. S3 Bucket: A bucket is created for potential data storage or backups.

5. User Data Scripts: Two script files (userdata.sh and userdata1.sh) are used to configure the EC2 instances with Apache and custom HTML pages during initialization.

Networking: Security groups are configured to allow HTTP (port 80) and SSH (port 22) access.
Public subnets ensure that EC2 instances and the load balancer are accessible from the internet.

Outputs: The load balancer's DNS name is outputted for easy access to the hosted application.
