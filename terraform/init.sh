#!/bin/bash
sudo -i
set -e

dnf install -y docker
dnf install -y nginx
dnf install -y postgresql17
dnf install -y git

cd /home/ec2-user

cat <<EOF > /home/ec2-user/.mb.env
MB_DB_HOST=[your-metabase_db_endpoint]
MB_DB_PORT=5432
MB_DB_NAME=metabasedb
MB_DB_USER=postgres
MB_DB_PASSWORD=[your-rds-password]
EOF

chmod 600 /home/ec2-user/.mb.env
chown ec2-user:ec2-user /home/ec2-user/.mb.env

git clone https://github.com/reonrash/databricks-job-tracker.git

cat <<EOF > /home/ec2-user/databricks-job-tracker/.env
DB_HOST=[your-jobs_db_endpoint]
DB_PORT=5432
DB_NAME=jobsdb
DB_USER=postgres
DB_PASS=[your-rds-password]
EOF

chmod 600 /home/ec2-user/databricks-job-tracker/.env
chown ec2-user:ec2-user /home/ec2-user/databricks-job-tracker/.env

cat <<'EOF' > /etc/nginx/conf.d/metabase.conf
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

systemctl start nginx
systemctl start docker

echo "Setup complete"
