#!/bin/bash
# Create or Delete Instance bastion
# Renato Marigo

# Variables
NAME="<name>"
PROJECT_ID="<project_id>"
REGION="southamerica-east1-b"
SHARED_SUBNET="<subnet_name>"
SERVICE_ACCOUNT="<acount@developer.gserviceaccount.com>"

echo "Create / Delete Bastion for CloudSQL"
echo "1 - Create Bastion"
echo "2 - Delete Bastion"

printf "Choose option: "
read OPTION

case $OPTION in
1)
gcloud beta compute --project=$PROJECT_ID instances create $NAME \
--zone=southamerica-east1-b \
--machine-type=g1-small \
--subnet=$SHARED_SUBNET \
--no-address \
--metadata=enable-oslogin=TRUE,enable-oslogin-2fa=True \
--maintenance-policy=MIGRATE \
--service-account=$SERVICE_ACCOUNT \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--image=debian-10-buster-v20200413 \
--image-project=debian-cloud \
--boot-disk-size=20GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=bastion-host-digital \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any
;;
2)
	# Delete cluster
    gcloud config set compute/zone southamerica-east1-b
	echo y | gcloud compute instances delete $NAME
	;;
*)
	echo "Option invalid"
	;;
esac