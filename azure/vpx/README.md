# Deploying two-armed mode Citrix ADC in Azure

## Requirements
- Terraform
- Azure subscription
- Azure Cloud Shell

We are using Azure Cloud Shell for the convenience that Terraform is already installed and it is maintained and kept up to date by Microsoft. Please follow this instruction to set up Azure Cloud Shell for the first time. https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart


## Instructions to Provision Citrix ADC

1. If you are going to do this lab for the first time, you need to accept Azure Marketplace Legal Terms. You only need to do this once by running the following command in Azure Cloud Shell

`az vm image terms accept --urn citrix:netscalervpx-130:netscaler10enterprise:130.47.24`

2. In Azure Cloud Shell, clone this repository by running the following commands. You may skip this command if you already clone the repository

`git clone https://github.com/citrix/cloud-native-getting-started.git`

3. Review `variables.tf` file and ensure that default `vnet_range`, `lan_subnet` and `wan_subnet` does not overlap with existing vnets in your default azure subscription.  You may customise the values of these two variables to suit your setup and save the file.

4. Initialise terraform by running this command

`terraform init`

5. Apply the terraform configuration by running this command

`terraform apply` and press `Y` when prompted.

Go back to your Azure Portal once the terraform script is completed and you will have Citrix ADC running in two armed-mode deployed in your subscription. 
