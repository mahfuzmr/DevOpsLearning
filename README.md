# DevOpsLearning
Repository for Learning DevOps Vm deployment with Terraform and Packer

# Target:  Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
With this example you will be able to write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
This repository contains 
1. tagging-policy (personal/TaggingPolicy.json) -> thsi policy will ensure tag names while creating resources
2. Packer template for creating ready image of Ubuntu 18.4.0 LTS (DevOpsLearning/personal/Packer/)
3. Terraform template for cluster VM creation using existing  Ubuntu 18.4.0 LTS packer image  (DevOpsLearning/personal/terraform/main.tf,vers.tf)
4. "solution.plan" as the plan output after runnuing "teraform-plan" command


Steps: 
Packer: After installation of packer test "packer -h" in the PowerSell to verify.
1. Using the server.json file change parameter as azure provided subscription:
        "client_id": "{{env `ARM_CLIENT_ID`}}",
		"client_secret": "{{env `ARM_CLIENT_SECRET`}}",
		"subscription_id": "{{env `ARM_SUBSCRIPTION_ID`}}"

2. Provide desire provisiones defaults are given.
3. Open Powersell and run command 
       packer build server.json

       This will create a Linux 18.4.0 LTs image in to azure subscription resource group. This image will be used later on by terraform script.

Policy: 
1. Open PowerShell login to azure subscription using command (azure CLI also has to be installed):

        az login - and follow the instruction

2. Using following command create the policy:

    az policy assignment  update --name tagging-policy --description "Policy enforcement for resource deployment" --display-name "Taggign policy to ensure environment and project tags on resource deployment" 

3. Using following command assign the created policy:
    policy assignment  create --policy tagging-policy 

4. Using following command list of policies can be shown:
    az policy assignment list

Terraform:

1. After installation of terraform test "terraform -h" in the PowerShell to verify.
2. Using the "main.tf" change test as desire

3.  If there is an existing resource group where the Vm needs to be installed. Following command needed to import existing resources:

    terraform import azurerm_resource_group.p01-rg /subscriptions/xxx.xxxx.xxxx.xxxx/resourceGroups/<resource-group-name>                                                                                         

4. Run command following in the PowerSell or Azure CLI to intialize terraform:

    terraform init / terraform init -upgrade for code modification

5. Run following command to validate writen code:

    terraform validate

6. After validation rin following command to see the plan

    terraform plan / terraform plan out solution.plan (to generate solution plan as file)

7. If there are no errors the Run following command to execute:

    terraform apply

8. Run command "terraform destroy" to delete all created resources from azure subscription resource group. (to release all the booked resources $$$$ )

Variables:

In the file vers.tf contains all the predefine variables that will be used while executing terraform examples. values can be set using keywords <defaults:>

### Output
ip-addres = "/subscriptions/.../publicIPAddresses/TestPublicIp1"



