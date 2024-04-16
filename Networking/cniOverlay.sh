# CNI (Container Network Interface) overlay in AKS (Azure Kubernetes Service) is a networking solution 
# that allows containers within a Kubernetes cluster to communicate with each other across different nodes.

# By using CNI overlay in AKS, you can simplify the networking configuration and management within your Kubernetes cluster, 
# while ensuring secure and reliable communication between containers.


# Setup Overlay Clusters variables
clusterName="myOverlayCluster"
resourceGroup="myResourceGroup"
location="westcentralus"
nodepoolName="newpool1"
subscriptionId=$(az account show --query id -o tsv)
vnetName="yourVnetName"
subnetName="yourNewSubnetName"
subnetResourceId="/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName"

# Create the AKS cluster
az aks create \
    --name $clusterName \
    --resource-group $resourceGroup \
    --location $location \
    --network-plugin azure \
    --network-plugin-mode overlay \
    --pod-cidr 192.168.0.0/16

# Add a nodepool to the dedicaated subnet
# This approach can be useful if you want to controll the ingress or egress IPs of the host from/towards targets
# in the same VNET or peered Vnets
az aks nodepool add  \
    --resource-group $resourceGroup \
    --cluster-name $clusterName \
    --name $nodepoolName \
    --node-count 1 \
    --mode system \
    --vnet-subnet-id $subnetResourceId

# Update an existing CNI cluster to use Overlay 
az aks update \
    --name $clusterName \
    --resource-group $resourceGroup \
    --network-plugin-mode overlay \
    --pod-cidr 192.168.0.0/16


# Update AKS cluster to use Azure CNI overlay
az aks update \
    --name $clusterName \
    --resource-group $resourceGroup \
    --network-plugin azure \
    --network-plugin-mode overlay 