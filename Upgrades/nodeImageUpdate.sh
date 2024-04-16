#!/bin/bash

# Set the resource group name and AKS cluster name
RESOURCE_GROUP=rg-aks-eastus
AKS_CLUSTER=aks-dev-eastus
#Confirm connectivity to the cluster
kubectl get nodes -o wide

#Check for available node image updates. Look at the latestNodeImageVersion 
az aks nodepool get-upgrades \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $AKS_CLUSTER \
    --nodepool-name nodepool1 \
    --output table

#get the current node image from our cluster
az aks nodepool show \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $AKS_CLUSTER \
    --name nodepool1 \
    --query nodeImageVersion

#Get the node image for each node, it is in the node's labels
kubectl describe nodes

#upgrade all nodes in all node pools
az aks upgrade \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER \
    --node-image-only

#Remove cluster from our kubeconfig file
kubectl config delete-context aks-sandbox-eastus
kubectl config delete-user clusterUser_aks-sandbox-eastus-rg_aks-sandbox-eastus
kubectl config delete-cluster aks-sandbox-eastus

#delete the cluster from the resource group
az aks delete --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER