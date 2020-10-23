#!/bin/bash
# Configure Bastion host to CloudSQL Proxy
# Please run script on home directory
# Renato Diniz Marigo
# CloudSQL Proxy References:
# https://cloud.google.com/sql/docs/postgres/sql-proxy
# Enable auto start:
# https://gist.github.com/goodwill/a981c2912ae6a83761a624f657f34d9f

# Variables
INSTANCE_NAME="<Connection name>"
BASTION_IP="<empty>"
GCP_SA_NAME="<service_account_name>"
PROJECT_ID="<your_project_id>"

sudo apt update -y
sudo apt install wget unzip git python3-pip postgresql-client -y

# Uninstall Gcloud 
sudo rm -rf /usr/lib/google-cloud-sdk
rm -rf /home/$USER/.config/gcloud

# Install Gcloud command
curl -LO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-299.0.0-linux-x86_64.tar.gz

# Extract Gcloud directory
tar -xvzf google-cloud-sdk-299.0.0-linux-x86_64.tar.gz

# Remove Gcloud download
rm google-cloud-sdk-299.0.0-linux-x86_64.tar.gz

# Install script
./google-cloud-sdk/install.sh

# Reload Bashrc
sleep 2
source /home/$USER/.bashrc

# Update Gcloud command
echo y | ~/google-cloud-sdk/bin/gcloud components update

# Autenticar na Google
~/google-cloud-sdk/bin/gcloud init

# Create a service account user in Google to acess CloudSQL proxy
gcloud iam service-accounts create $GCP_SA_NAME --display-name $GCP_SA_NAME

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter=displayName:$GCP_SA_NAME \
    --format='value(email)')

# Add iam policy binding
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --role roles/cloudsql.client \
    --member serviceAccount:$SA_EMAIL

# Generate Json Key to user
~/google-cloud-sdk/bin/gcloud iam service-accounts keys create ./key.json \
  --iam-account $GCP_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com

# Install CloudSQL Proxy command
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy

chmod +x cloud_sql_proxy

# Run CloudSQL Proxy on Startup

sudo cp cloud_sql_proxy /usr/local/bin
sudo mkdir /var/run/cloud-sql-proxy
sudo chown root:root /var/run/cloud-sql-proxy

sudo mkdir /var/local/cloud-sql-proxy
sudo chown root:root /var/local/cloud-sql-proxy
sudo chown root:root /var/local/

sudo cp key.json /var/local/cloud-sql-proxy

BASTION_IP=`ip a | grep "inet\ " | grep -v 127 | awk ' {print $2}' | cut -d/ -f1`

sudo tee /lib/systemd/system/cloud-sql-proxy.service <<EOF
[Install]
WantedBy=multi-user.target

[Unit]
Description=Google Cloud Compute Engine SQL Proxy
Requires=networking.service
After=networking.service

[Service]
Type=simple
RuntimeDirectory=/var/run/cloud-sql-proxy
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/cloud_sql_proxy -dir=/var/run/cloud-sql-proxy --instances=$INSTANCE_NAME=tcp:$BASTION_IP:5432 -credential_file=/var/local/cloud-sql-proxy/key.json
Restart=always
StandardOutput=journal
User=root
EOF

sudo systemctl daemon-reload
sudo systemctl enable cloud-sql-proxy
sudo reboot

# For tests
# psql -h BASTION_IP -U user -d database