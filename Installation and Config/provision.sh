#!/bin/bash

# Set the resource group name and AKS cluster name
RESOURCE_GROUP=rg-aks-dev-eastus
AKS_CLUSTER=aks-dev-eastus

ACR_NAME=acrdeveastus

# Create a resource group
az group create --name $RESOURCE_GROUP --location eastus

# Create an AKS cluster with multiple zones
# Networking plugin Azure CNI, Using Azure Network Policy
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER \
    --node-count 3 \
    --zones 1 2 3 \
    --network-plugin azure \
    --network-policy azure \
    --enable-managed-identity \
    --generate-ssh-keys

# Using kubenet and calico
# az aks create \
#     --resource-group $RESOURCE_GROUP \
#     --name $AKS_CLUSTER \
#     --node-count 3 \
#     --zones 1 2 3 \
#     --network-plugin kubenet \
#     --network-policy calico \
#     --enable-managed-identity \
#     --generate-ssh-keys

# Attach using acr-name
az aks update -n $AKS_CLUSTER -g $RESOURCE_GROUP --attach-acr $ACR_NAME

# Get the AKS cluster credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER

# Set the context to the AKS cluster
kubectl config use-context $AKS_CLUSTER

# Deploy a hello-world image into the cluster
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0

# Create a load balancer to access the hello-world image
kubectl expose deployment hello-world --type=LoadBalancer --port=80 --target-port=8080

# Show what is going on in the cluster
kubectl get nodes
kubectl get pods
kubectl get services

# remove deployments
#kubectl delete deployment hello-world

# remove services
#kubectl delete service hello-world