#!/bin/bash

# Set the resource group name and AKS cluster name
RESOURCE_GROUP=rg-aks-eastus
AKS_CLUSTER=aks-dev-eastus

#view rolebndings
kubectl get rolebindings --namespace dev

#remove rolebindings from aks cluster
kubectl delete rolebinding rolebindingdev --namespace dev
kubectl delete rolebinding rolebindingprod --namespace prod

#view roles from aks cluster
kubectl get roles --namespace dev

#remove roles from aks cluster
kubectl delete role roledev --namespace dev
kubectl delete role roleprod --namespace prod

#view namespaces from aks cluster
kubectl get namespaces

#remove namespaces from aks cluster
kubectl delete namespace dev
kubectl delete namespace prod


#Remove any credentials created from our kubeconfig file
kubectl config delete-context aks-sandbox-eastus-admin
kubectl config delete-context aks-sandbox-eastus
kubectl config delete-user clusterUser_aks-sandbox-eastus-rg_aks-sandbox-eastus
kubectl config delete-user clusterAdmin_aks-sandbox-eastus-rg_aks-sandbox-eastus
kubectl config delete-cluster aks-sandbox-eastus

#delete cluster
az aks delete --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER

#remove AD group 
az ad group delete --group aks-developer-access