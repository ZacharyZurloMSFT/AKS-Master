#!/bin/bash

# Set the resource group and cluster name variables
RESOURCE_GROUP=rg-aks-eastus
AKS_CLUSTER=aks-dev-eastus

# NODES
# Update an existing cluster to enable the cluster autoscaler on the node pool for the cluster and sets a minimum of one and maximum of three nodes
az aks update \
--resource-group $RESOURCE_GROUP \
--name $AKS_CLUSTER \
--enable-cluster-autoscaler \
--min-count 1 \
--max-count 3

#PODS
# Apply the configuration in nginx.yaml to the Kubernetes cluster
kubectl apply -f nginx.yaml

# Get the deployment named nginx-deployment
kubectl get deployment nginx-deployment

# Get the pods in the Kubernetes cluster and display additional information about them
kubectl get pods -o wide

# Autoscale the deployment named nginx-deployment based on CPU usage, with a minimum of 2 replicas, a maximum of 5 replicas, and a target CPU usage of 50%
kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=2 --max=5

# Get the Horizontal Pod Autoscaler (HPA) named nginx-deployment
kubectl get hpa

# Edit the HPA named nginx-deployment
# kubectl edit hpa

# Get the pods in the Kubernetes cluster and display additional information about them
kubectl get pods -o wide

# This script retrieves the IP address of the nginx service running on an AKS cluster, opens a web browser to the service's IP address, runs a load test using httperf, and then retrieves the horizontal pod autoscaler (HPA) and pod information. Finally, it clears the console.

# Retrieve the IP address of the nginx service
SERVICEIP=$(kubectl get service nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Retrieve pod information
kubectl get pods -o wide

# Run a load test using httperf
kubectl run -i --rm httperfpod --image=cyrilbkr/httperf --restart=Never -- /bin/sh -c ("httperf --server " + $SERVICEIP + " --wsess=10,1000,0 --rate=1")

# Retrieve the HPA
kubectl get hpa

# Retrieve pod information
kubectl get pods -o wide
