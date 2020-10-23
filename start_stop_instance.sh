#!/bin/bash
# Start / Stop Bastion Host
# Renato Diniz Marigo

# Variables
INSTANCE_NAME="<instance_name>"
echo "Start / Stop Bastion for CloudSQL"
echo "1 - Start Bastion"
echo "2 - Stop Bastion"

printf "Choose option: "
read OPTION

case $OPTION in
1)
gcloud config set compute/zone southamerica-east1-b 
gcloud config set compute/region southamerica-east1
gcloud compute instances start $INSTANCE_NAME
echo "IP da instancia:"
gcloud compute instances describe $INSTANCE_NAME | grep networkIP
;;
2)
gcloud config set compute/zone southamerica-east1-b 
gcloud config set compute/region southamerica-east1
gcloud compute instances stop $INSTANCE_NAME
;;
*)
echo "Option invalid"
;;
esac

