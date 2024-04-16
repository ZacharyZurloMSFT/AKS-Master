#AKS nodes are cordoned and drained to minimize any potential disruptions to running applications
#AKS will
# add a buffer node, cordon and drain one of the old nodes to minimize disruption
# once drained, it is reimaged to receive the new version and become the buffer node
# process repeats until all nodes have been upgraded

KUBERNETES_VERSION=1.28.3
#Gets the upgrades available for the AKS cluster
az aks get-upgrades --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER
#Runs the upgrade
az aks upgrade --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --kubernetes-version $KUBERNETES_VERSION
#configure automatic upgrades
az aks update --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --auto-upgrade-channel patch
#confirm success
az aks show --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --output table