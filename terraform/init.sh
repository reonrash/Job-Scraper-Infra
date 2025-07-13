#!/bin/bash
sudo -i
set -e

dnf install -y docker
dnf install -y nginx
dnf install -y postgresql17
dnf install -y git

git clone https://github.com/reonrash/databricks-job-tracker.git

cat <<'EOF' > /etc/nginx/conf.d/metabase.conf
server {
    listen 80;
    server_name _;  # Accept all requests; replace with domain if you have one

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



