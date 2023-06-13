resource "aws_db_subnet_group" "drupal_db_subnet_group" {
  name       = "drupal-db-subnet-group"
  subnet_ids = module.vpc.private_subnets  # Replace with your desired subnets
  depends_on = [ module.vpc ]
}

resource "aws_rds_cluster" "drupal_db_cluster" {
  cluster_identifier         = "drupal-db-cluster"
  engine                     = "aurora-mysql"
  engine_version             = "5.7"
#  engine                     = "aurora-mysql"
#  engine_version             = "5.7.mysql_aurora.2.10.1"
  database_name              = "drupal"
  master_username            = "admin"  # Replace with your desired master username
  master_password            = "password"  # Replace with your desired master password
  backup_retention_period    = 7  # Replace with your desired backup retention period in days
  preferred_backup_window    = "03:00-04:00"  # Replace with your preferred backup window
  preferred_maintenance_window = "sun:05:00-sun:06:00"  # Replace with your preferred maintenance window
  db_subnet_group_name = aws_db_subnet_group.drupal_db_subnet_group.name
  skip_final_snapshot       = true

  tags = {
    Name = "drupal-db-cluster"
  }
}

#resource "aws_rds_cluster_instance" "drupal_db_instance" {
 # cluster_identifier = aws_rds_cluster.drupal_db_cluster.id
  #instance_class     = "db.t4g.medium"  # Replace with your desired instance type
  #engine             = "aurora"
  #engine_version             = "5.7.mysql_aurora.2.10.1"
  #tags = {
   # Name = "drupal-db-instance"
 # }
#}
