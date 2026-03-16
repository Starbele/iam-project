#!/bin/bash

# IAM Roles and Secure Access Automation


set -e

# VARIABLES
RESOURCE_GROUP="IAM-Project-RG"
LOCATION="eastus"
VNET_NAME="IAM-VNet"
WEB_SUBNET="WebSubnet"
DB_SUBNET="DBSubnet"
WEB_GROUP="WebAdmins"
DB_GROUP="DBAdmins"


echo " STEP 1: Creating Resource Group"

az group create --name $RESOURCE_GROUP --location $LOCATION
echo " Resource Group created."


echo " STEP 2: Creating Virtual Network"

az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16
echo " Virtual Network created."


echo " STEP 3: Creating Web and DB Subnets"

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $WEB_SUBNET \
  --address-prefix 10.0.1.0/24

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $DB_SUBNET \
  --address-prefix 10.0.2.0/24
echo " Web and DB Subnets created."


echo " STEP 4: Creating Azure AD Groups"

az ad group create --display-name $WEB_GROUP --mail-nickname "WebAdmins"
az ad group create --display-name $DB_GROUP  --mail-nickname "DBAdmins"
echo " AD Groups created."


echo " STEP 5: Assigning Reader Role to DBAdmins"

DB_GROUP_ID=$(az ad group show --group $DB_GROUP --query id -o tsv)
RG_SCOPE="/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP"

az role assignment create \
  --assignee-object-id $DB_GROUP_ID \
  --assignee-principal-type Group \
  --role "Reader" \
  --scope $RG_SCOPE
echo " Reader role assigned to DBAdmins."


echo " STEP 6: Creating Test Users"

TENANT_DOMAIN=$(az rest --method get \
  --url "https://graph.microsoft.com/v1.0/domains" \
  --query "value[?isDefault].id" -o tsv)

az ad user create \
  --display-name "Web Admin Test" \
  --user-principal-name "webadmin.test@$TENANT_DOMAIN" \
  --password "TempPass@1234" \
  --force-change-password-next-sign-in false

az ad user create \
  --display-name "DB Admin Test" \
  --user-principal-name "dbadmin.test@$TENANT_DOMAIN" \
  --password "TempPass@1234" \
  --force-change-password-next-sign-in false
echo " Test users created."

echo "================================================"
echo " STEP 7: Adding Users to Their Groups"
echo "================================================"
WEB_USER_ID=$(az ad user show --id "webadmin.test@$TENANT_DOMAIN" --query id -o tsv)
DB_USER_ID=$(az ad user show  --id "dbadmin.test@$TENANT_DOMAIN"  --query id -o tsv)
WEB_GROUP_ID=$(az ad group show --group $WEB_GROUP --query id -o tsv)

az ad group member add --group $WEB_GROUP_ID --member-id $WEB_USER_ID
az ad group member add --group $DB_GROUP_ID  --member-id $DB_USER_ID
echo " Users added to groups."


echo " STEP 8: Validating Role Assignments"

echo "--- Role assignments for DBAdmins ---"
az role assignment list \
  --assignee $DB_GROUP_ID \
  --scope $RG_SCOPE \
  --output table

echo "--- Members of WebAdmins ---"
az ad group member list --group $WEB_GROUP --output table

echo "--- Members of DBAdmins ---"
az ad group member list --group $DB_GROUP --output table

echo ""
echo " ALL DONE! IAM Setup Complete."