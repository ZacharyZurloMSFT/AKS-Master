#!/bin/bash

# Set the resource group name and AKS cluster name
RESOURCE_GROUP=rg-aks-eastus
AKS_CLUSTER=aks-dev-eastus

# update aks cluster to enable azure rbac
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER \
    --enable-azure-rbac \
    --enable-aad

#get out AKS cluster ID used to scope our role to resources in the cluster
AKS_CLUSTER_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --query id --output tsv)
echo $AKS_CLUSTER_ID

#Get the admin certificate based credential
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER \
    --admin

#Create namespace for dev and prod. Add deployments to each namespace
kubectl create namespace dev
kubectl create namespace prod
kubectl create deployment hello-world-dev --image=gcr.io/google-samples/hello-app:1.0 --namespace dev
kubectl create deployment hello-world-prod --image=gcr.io/google-samples/hello-app:1.0 --namespace prod

#Get our AAD credential
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER

#delete credential cache
kubelogin remove-tokens

#config get contexts
kubectl config get-contexts

#test access to the workloads in the prod and dev namespaces. This should fail
kubectl get pods --namespace dev
kubectl get pods --namespace prod

#Accessing a cluster with a read only user, the AKS RBAC Reader role for a specific namesapce
AAD_MEMBER_ID=$(az ad user list --query "[?contains(displayName, 'Zachary Zurlo')].[id]" --output tsv)
echo $AAD_MEMBER_ID

#assign our user to the writer role for the dev namespace


#create azure role assignment for AKS RBAC writer using the member ID and the AKS Cluster ID
MSYS_NO_PATHCONV=1 az role assignment create \
    --role "Azure Kubernetes Service RBAC Writer" \
    --assignee $AAD_MEMBER_ID \
    --scope /subscriptions/834670d8-bd1b-4bc7-b735-7420b64637fb/resourceGroups/aks-sandbox-eastus-rg/providers/Microsoft.ContainerService/managedClusters/aks-sandbox-eastus/namespaces/dev

#I should be able to read from dev but not prod
kubectl get pods --namespace dev #This should work since were in the AKS RBAC Writer role
kubectl get pods --namespace prod #This should fail since we don't have access to that namespace

#I should be able to update the deployment in dev, but not prod
kubectl set image deployment hello-world-dev hello-app=gcr.io/google-samples/hello-app:2.0 --namespace dev
kubectl set image deployment hello-world-prod hello-app=gcr.io/google-samples/hello-app:2.0 --namespace prod

