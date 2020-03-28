# Deploying Kubernetes cluster on Ubuntu VMs running in Azure

## Requirements
- Terraform
- Azure subscription
- Azure Cloud Shell

We are using Azure Cloud Shell for the convenience that Terraform is already installed and it is maintained and kept up to date by Microsoft. Please follow this instruction to set up Azure Cloud Shell for the first time. https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart

## Instruction to Provision the VMs

1. In Azure Cloud Shell, clone this repository by running the following commands. You may skip this command if you already clone the repository

`git clone https://github.com/citrix/cloud-native-getting-started.git`

2. Review `variables.tf` file and ensure that default `vnet_range` and `lan_subnet` does not overlap with existing vnets in your default azure subscription.  You may customise the values of these two variables to suit your setup and save the file.

3. Initialise terraform by running this command

`terraform init`

4. Apply the terraform configuration by running this command

`terraform apply` and press `Y` when prompted.

Go back to your Azure Portal once the terraform script is completed and you will have 3 Linux VMs deployed in your subscription. One VM will be setup as the Master Node and the remaining two will be Worker Nodes.


## Instruction to Provision the Master Node

5. Ssh to Node0-VM. Please note this will be Master Node. You can ssh to Node0-VM from AzureCLI using the assigned Node0-VM Public IP Address that you can obtain from the Azure Portal.

6. Assign unique hostname for Master Node.

`sudo hostnamectl set-hostname master-node`

7. Initialise Kubernetes on Master Node

`sudo kubeadm init --pod-network-cidr=10.244.0.0/16`

Once this command is completed, it will display a 
`kubeadm join` message at the end. Make a note of the whole entry as this will be used to join the worker nodes to the cluster.

8. Enter the following commands to create a directory for the cluster.

`kubernetes-master:~$ mkdir -p $HOME/.kube`
`kubernetes-master:~$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config`
`kubernetes-master:~$ sudo chown $(id -u):$(id -g) $HOME/.kube/config1

9. Deploy pod network the cluster. A pod network is a way to allow communications between different nodes in the cluster. We will be using `flannel` as the virtual network.

`sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml`

10. Verify that the kubernetes cluster is up and running. 

`kubectl get pods --all-namespaces`


## Instruction to Join Worker Nodes to Cluster

11. Ssh to Node1-VM. This will be your Worker01 node.

12. Assign unique name for Worker Node.

`sudo hostnamectl set-hostname worker01`

Repeat the above command by assigning a unique name for your second worker node on Node2-VM.

13. As indicated in Step 7, enter `kubeadm join` command on each of your Worker Nodes that you noted from Step 7 above.

`kubeadm join --discovery-token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:1234..cdef 1.2.3.4:6443`

Replace the alphanumeric codes with those from your master server. Repeat for each worker node on the cluster. Wait a few minutes; then you can check the status of the nodes.

14. Repeat Step 11 to Step 13 for your second Worker Node. 

## Validate if Worker Nodes have joined the cluster

15. Run the following command on the Master Node.

`kubectl get nodes`

The system should display the worker nodes that you joined to the cluster.


## Conclusion

After following the above steps mentioned in this article, you should now have Kubernetes cluster running in three Ubuntu VMs in Azure.







