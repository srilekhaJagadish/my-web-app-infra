# 1. ALB Security Group (Public)
# Logic: Allows external traffic from the internet on port 80.
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow public HTTP traffic"
  vpc_id      = module.vpc.vpc_id

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
}

# 2. EC2 Security Group (Private)
# Logic: Only accepts traffic from the ALB.
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. EFS Security Group (Private Storage)
# Logic: Only allows NFS traffic (port 2049) from the EC2 instances.
resource "aws_security_group" "efs_sg" {
  name        = "${var.project_name}-efs-sg"
  description = "Allow NFS traffic from EC2 nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}

# 4. RDS Security Group (Private Database)
# Logic: Only allows Database traffic (port 5432 for Postgres) from EC2 instances.
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow DB traffic from EC2 nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}