#!/bin/bash

# Set the resource group name and AKS cluster name
RESOURCE_GROUP=rg-aks-eastus
AKS_CLUSTER=aks-dev-eastus

az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER \
    --admin

kubectl config get-contexts

#confirm access
kubectl get nodes

az ad group create \
    --display-name "aks-developer-access" \
    --mail-nickname "aks-developer-access"

AAD_GROUP_ID=$(az ad group show --group "aks-developer-access" --query id --output tsv)
echo $AAD_GROUP_ID

AAD_MEMBER_ID=$(az ad user list --query "[?contains(displayName, 'Zachary Zurlo')].[id]" --output tsv)
echo $AAD_MEMBER_ID
az ad group member add --group aks-developer-access --member-id $AAD_MEMBER_ID

kubectl create namespace dev
kubectl create namespace prod
kubectl create deployment hello-world-dev --image=gcr.io/google-samples/hello-app:1.0 --namespace dev
kubectl create deployment hello-world-prod --image=gcr.io/google-samples/hello-app:1.0 --namespace prod


kubectl get pods --namespace dev
kubectl get pods --namespace prod


kubectl create role roledev --namespace dev --verb=* --resource=deployments,pods

kubectl create rolebinding rolebindingdev --namespacedev --role=roledev --group=$AAD_GROUP_ID

kubelogin remove-tokens

kubectl config use-context $AKS_CLUSTER

kubectl config get-contexts

#This will launch a web browser interactactive login
kubectl get pods --namespace dev #this should work
kubectl get pods --namespace prod #this should fail
kubectl get nodes #this should fail

kubectl set image deployment hello-world-dev hello-world=gcr.io/google-samples/hello-app:2.0 --namespace dev #this should work
kubectl set image deployment hello-world-prod hello-world=gcr.io/google-samples/hello-app:2.0 --namespace prod #this should fail


#Clean up from this demo
az ad group delete --group aks-developer-access

#View/delete kubernets config users and contexts
