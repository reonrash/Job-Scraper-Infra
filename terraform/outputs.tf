# Output the Public IP of the EC2 instance
output "ec2_public_ip" {
  description = "The public IP address of the Metabase scraper EC2 instance."
  value       = aws_instance.metabase_scraper.public_ip
}

# Output the Endpoints for the RDS instances
output "metabase_db_endpoint" {
  description = "The endpoint for the Metabase RDS PostgreSQL instance."
  value       = aws_db_instance.metabase_db.address
}

output "jobs_db_endpoint" {
  description = "The endpoint for the Jobs RDS PostgreSQL instance."
  value       = aws_db_instance.jobs_db.address
}
