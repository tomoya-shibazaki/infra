# SSM Parameter Store
data "aws_ssm_parameter" "database_name" {
  name = "MYSQL_DATABASE"
}

data "aws_ssm_parameter" "database_user" {
  name = "MYSQL_USER"
}

data "aws_ssm_parameter" "database_password" {
  name = "MYSQL_PASSWORD"
}

locals {
  name = "${var.prefix}-rds-mysql"
}

# Security Group
resource "aws_security_group" "this" {
  name        = local.name
  description = local.name
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.name}"
  }
}

resource "aws_security_group_rule" "mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.this.id
}

# Subnet Group
resource "aws_db_subnet_group" "this" {
  name        = local.name
  description = local.name
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]
}

# RDS Cluster Parameter Group
resource "aws_rds_cluster_parameter_group" "this" {
  name   = local.name
  family = "aurora-mysql5.7"

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# RDS Cluster
resource "aws_rds_cluster" "this" {
  cluster_identifier = local.name

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = ["${aws_security_group.this.id}"]

  engine = "aurora-mysql"
  port   = "3306"

  database_name   = data.aws_ssm_parameter.database_name.value
  master_username = data.aws_ssm_parameter.database_user.value
  master_password = data.aws_ssm_parameter.database_password.value

  skip_final_snapshot = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
}

# RDS Cluster Instance
resource "aws_rds_cluster_instance" "this" {
  identifier         = local.name
  cluster_identifier = aws_rds_cluster.this.id

  engine = "aurora-mysql"

  instance_class = "db.t3.small"
}



output "rds_endpoint" {
  value = aws_rds_cluster.this.endpoint
}
