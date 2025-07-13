# Databricks Job Scraper: Infrastructure Deployment

This guide helps you deploy the AWS infrastructure needed for a Databricks job scraper using Terraform. We'll set up an EC2 instance, two PostgreSQL RDS databases (one for job data, one for Metabase), metabase application, and some networking.

-----

## What You'll Need

  * An **AWS account** with configured **access keys**.
  * An **EC2 key pair**.
  * **Terraform** installed.

-----

## Deployment Steps

### Step 1: Prep Terraform

In your project directory, run:

```bash
terraform validate
terraform plan
```

This checks your config and shows what Terraform will do.

### Step 2: Deploy Infrastructure

To kick off the deployment, type:

```bash
terraform apply
```

When prompted, type `yes`. This usually takes about 5 minutes.

You'll see output like this, grab these values:

```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:
ec2_public_ip = "3.84.222.0"
jobs_db_endpoint = "jobs-db.cyp4keqss5qm.us-east-1.rds.amazonaws.com"
metabase_db_endpoint = "metabase-db.cyp4keqss5qm.us-east-1.rds.amazonaws.com"
```

-----

## Step 3: Set Up Environment Files

There are two env files already created but need user input for two fields. **These are examples – fill them in with your actual database hosts and passwords\!**

### For the Job Scraper (`.env`) cd /home/ec2-user/databricks-job-tracker/.env:

```env
DB_HOST=[your_jobs_db_endpoint_from_terraform_output]
DB_PORT=5432
DB_NAME=jobsdb
DB_USER=postgres
DB_PASSWORD=[your_chosen_jobs_db_password]
```

### For Metabase (`.mb.env`) cd /home/ec2-user/.mb.env:

```env
MB_DB_HOST=your_[metabase_db_endpoint_from_terraform_output]
MB_DB_PORT=5432
MB_DB_NAME=metabasedb
MB_DB_USER=postgres
MB_DB_PASS=[your_chosen_metabase_db_password]
```

-----

## Step 4: Configure EC2 & Run Scraper

1.  **SSH into your EC2 instance:**

    ```bash
    ssh -i /path/to/your/keypair.pem ec2-user@<ec2_public_ip>
    ```

2.  **Go to your project directory:**

    ```bash
    cd databricks-job-tracker
    ```

3.  **Create/edit your `.env` files** in this directory using a text editor (like `nano` or `vim`) and paste in your specific details from Step 3.

4.  **Build your scraper's Docker image:**

    ```bash
    docker build -t scrape .
    ```

5.  **Run the scraper:**

    ```bash
    docker run --rm --env-file .env scrape
    ```

-----

## Step 5: Run Metabase

On your EC2 instance, run the Metabase container:

```bash
docker run -d \
  --name metabase \
  --env-file .mb.env \
  -p 3000:3000 \
  metabase/metabase
```

Give it a minute or two to start. Then, open your browser and go to:

`http://[ec2_public_ip]:3000`

Follow the prompts to set up Metabase and connect it to your job data database.

-----

## Step 6: Tear Down Infrastructure

When you're done, destroy all resources on related to this proj (in your project directory) to avoid charges:

```bash
terraform destroy
```

Type `yes` when asked.
