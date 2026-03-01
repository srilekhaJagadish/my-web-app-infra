# --- Amazon EFS for Shared Staging ---
resource "aws_efs_file_system" "staging" {
  creation_token = "fomax-efs"
  encrypted      = true
  tags           = { Name = "FLS-Staging-Area" }
}

resource "aws_efs_mount_target" "staging_mt" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.staging.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

# --- Multi-AZ RDS Instance ---
resource "aws_db_instance" "database" {
  allocated_storage      = 20
  engine                 = "postgres"
  instance_class         = "db.t3.medium"
  db_name                = "fomaxdb"
  username               = "dbadmin"
  password               = var.db_password
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az               = true # Required for High Availability
  skip_final_snapshot    = true
}