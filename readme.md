# AKS dual deployment and System Stress Test

Purpose of this repository is to:
1. Deploy Standard and Automatic AKS clusters that are as similar as possible
2. Break system critical pods and monitor the results.

Each cluster consists of:
- **System Node Pool** (3 nodes, configurable VM size, availability zones 1-3, autoscaling enabled)
- **User Node Pool** (3 nodes, configurable VM size, availability zones 1-3, autoscaling enabled)
- **Azure Policy Add-on** enabled for governance and compliance (default on AKS)
- **Azure Monitor for Containers** for external monitoring of cluster health
- **aks-store-demo** deployed via Helm, ensuring pods run in all zones.

The repository includes a stress test to overload the system node pool and measure the effects on the application and cluster stability.

## Prerequisites

- **Terraform** (
- **Azure CLI**
- **kubectl**
- **kubelogin**
- **Helm**
- Quota available for the requested VM sizes in the target region
- an Azure Entra ID group and tenant

### 2. Test prerequisites are installed
```sh
./0-test-prereqs.sh
```

List of SKU options that are in all 3 zones (replace northeurope):
```
 az vm list-skus --location northeurope --resource-type virtualMachines --output table | grep -E "1,2,3" | grep -v "NotAvailableForSubscription"
```
List of SKU options that are in all 3 zones (replace northeurope and SKUs from previous result):
```
az vm list-usage --location northeurope --output table | grep -E "Total Regional|standard Dadv6|standard Dalv6|standard Dav6|standard Eadv6|standard Eav6|Standard Falsv6|Standard Famsv6|Standard Fasv6|Standard M"
```

## Configuration Options

Key variables that can be customized (set in `terraform.tfvars` or via command line):

| Variable | Default | Description |
|----------|---------|-------------|
| `location` | northeurope | Azure region for deployment |
| `sku` | Standard_D8ds_v4 | VM size for node pools |
| `kubernetes_version` | 1.30.9 | Kubernetes version |
| `system_node_count` | 3 | Initial system nodes per cluster |
| `user_node_count` | 3 | Initial user nodes per cluster |
| `deploy_standard` | true | Set to false to skip standard cluster |
| `deploy_automatic` | true | Set to false to skip automatic cluster |

## Infrastructure Deployment

### 1. Enable AKS Automatic Preview Feature
```sh
az feature register --namespace Microsoft.ContainerService --name AutomaticSKUPreview
# Wait a while
az provider register --namespace Microsoft.ContainerService
# Wait a while
```

### 2. Deploy Infrastructure and authenticate
```sh
./1-infra.sh
```

### 2. Import AKS Store Demo and other images to ACR
```sh
./2-import-images.sh
```

### 3a (optional). Use helm to install the AKS Store Demo so we have something to test against in user land
```sh
./3-aks-store-demo-optional.sh
```

### 3b (optional). Use helm to install Headlamp
```sh
./3b-headlamp-optional.sh
```

### 4. System Stress test
```sh
./4-stresstest.sh
```

Or manually:
```sh
kubectl apply -f system-stress.yaml
kubectl delete pods -n kube-system -l k8s-app=kube-dns
kubectl get pods -n kube-system -w
```

### 5. Testing and Monitoring

#### Verify Repository Setup
Run the test script to verify that your environment has all the prerequisites and the repository is set up correctly:
```sh
./test-functionality.sh
```

This will check for required tools, validate your terraform configuration, and verify cluster existence (if already deployed).

#### Continuous Cluster Monitoring
To continuously monitor the health of your AKS clusters and detect any system pool failures:
```sh
./monitor-clusters.sh
```

This script checks:
- Node status in both clusters
- System pods health
- Headlamp installation status
- System pool resource usage

Press Ctrl+C to stop monitoring.

### 6. Cleanup
```sh
./5-cleanup.sh
```