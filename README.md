# Databricks Job Scraper Infrastructure Deployment

## Purpose

Deploy AWS infrastructure using Terraform, consisting of:  
- 1 EC2 instance  
- 2 PostgreSQL RDS databases  
- 2 Security Groups  
- 1 DB Subnet Group  

This infrastructure supports running and storing data collected by a Databricks job listings scraper.

## Requirements

- AWS account  
- Configured AWS access key  
  (See: [Creating Access Keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-key-self-managed.html#Using_CreateAccessKey))  
- Configured key pair for EC2 
- Terraform installed  
