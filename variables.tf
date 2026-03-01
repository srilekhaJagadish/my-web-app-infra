variable "aws_region" {
  description = "The AWS region to deploy the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The prefix used for naming all resources."
  type        = string
  default     = "fomax-stack"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# --- Instance Configuration ---
variable "instance_type" {
  description = "The EC2 instance type for the Spring Boot nodes."
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "The AMI ID for the Spring Boot nodes (Amazon Linux 2023 recommended)."
  type        = string
  # Example: Amazon Linux 2023 AMI for us-east-1
  default     = "ami-0cff7528ff583bf9a"
}

# --- Database Configuration ---
variable "db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "fomaxdb"
}

variable "db_username" {
  description = "Username for the RDS instance."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Password for the RDS instance. (Marked sensitive to hide from logs)."
  type        = string
  sensitive   = true
}

# --- Auto Scaling Configuration ---
variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the ASG."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances to handle the landing surge."
  type        = number
  default     = 20
}

variable "cpu_target_threshold" {
  description = "The CPU percentage at which the ASG should scale out."
  type        = number
  default     = 60.0
}