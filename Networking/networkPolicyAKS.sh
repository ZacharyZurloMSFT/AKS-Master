#!/bin/bash

# Set the resource group name and AKS cluster name
RESOURCE_GROUP=rg-aks-eastus
AKS_CLUSTER=aks-dev-eastus

# Create an AKS cluster with Azure Network Plugin and Azure Network Policy manager
# Calico is also an option for network policy
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER \
    --network-plugin azure \
    --network-policy azure \
    --generate-ssh-keys

#Get the kubeconfig to log into the cluster
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER

#Confirm connectivity to the cluster
kubectl get nodes -o wide

#deploy and test connectivity with the network policy
kubectl apply -f deploymentNetworkPolicy.yaml

#check on the deployment of our pods and service
kubectl get deployment
kubectl get service

#Test access to the application running in our pod before moving on to applying the network policy
#Here we are accessing the service which will load balance to any of  the pods in the service
kubectl run network-test --image=radial/busyboxplus:curl -i --tty --rm
curl http://hello-world.default.svc.cluster.local
exit