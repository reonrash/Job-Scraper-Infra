# Databricks Job Scraper Infrastructure Deployment

## Purpose

Deploy AWS infrastructure using Terraform, consisting of:

* 1 EC2 instance
* 2 PostgreSQL RDS databases
* 2 Security Groups
* 1 DB Subnet Group

This infrastructure supports running and storing data collected by a Databricks job listings scraper.

## Requirements

* AWS account
* Configured AWS access key
  [Creating Access Keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-key-self-managed.html#Using_CreateAccessKey)
* Configured key pair for EC2
* Terraform installed

---

## Deployment Walkthrough

### Step 1: Initialize and Plan Terraform

In your project directory, run:

```bash
terraform validate
terraform plan
```

`terraform validate` should run successfully.
`terraform plan` will show you the proposed changes.

### Step 2: Apply Terraform Configuration

Run:

```bash
terraform apply
```

When prompted, type:

```bash
yes
```

Provisioning takes around 5 minutes.

Example output:

```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:
ec2_public_ip = "3.84.222.0"
jobs_db_endpoint = "jobs-db.cyp4keqss5qm.us-east-1.rds.amazonaws.com"
metabase_db_endpoint = "metabase-db.cyp4keqss5qm.us-east-1.rds.amazonaws.com"
```

---

## Step 3: Set Up Environment Files

### Example `.env` file for Job Scraper:

```env
DB_HOST=your_database_host
DB_PORT=your_database_port
DB_NAME=your_database_name
DB_USER=your_database_user
DB_PASSWORD=your_database_password
```

---

## Step 4: Configure EC2 Instance

SSH into the EC2 instance:

```bash
ssh -i ~/jobdash-ec2-key.pem ec2-user@3.84.222.0
sudo -i
cd /databricks-job-tracker
touch .env
chmod 600 .env
vim .env
```

Paste in:

```env
DB_HOST=[provided by AWS jobs_db_endpoint]
DB_PORT=5432
DB_NAME=jobsdb
DB_USER=postgres
DB_PASSWORD=[your password]
```

### Step 5: Build and Run Scraper Docker Image

Build the image:

```bash
docker build -t scrape .
```

Run the container:

```bash
docker run --rm --env-file .env scrape
```

---

## Step 6: Configure Metabase Container

Create Metabase environment file:

```bash
touch mb.env
chmod 600 mb.env
vim mb.env
```

Contents:

```env
MB_DB_HOST=[provided by AWS metabase_db_endpoint]
MB_DB_PORT=5432
MB_DB_NAME=jobsdb
MB_DB_USER=postgres
MB_DB_PASS=[your password]
```

Run Metabase container:

```bash
docker run -d \
  --name metabase \
  --env-file mb.env \
  -p 3000:3000 \
  metabase/metabase
```

Visit `http://[ec2_public_ip]:3000` in your browser to set up Metabase and connect it to your job data database.

---

## Step 7: Tear Down Infrastructure

To destroy all resources:

```bash
terraform destroy
```

When prompted:

```bash
yes
```
