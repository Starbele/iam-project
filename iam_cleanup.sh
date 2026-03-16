#!/bin/bash

# BONUS: Cleanup / Revoke Access Script


RESOURCE_GROUP="IAM-Project-RG"
DB_GROUP="DBAdmins"
WEB_GROUP="WebAdmins"

TENANT_DOMAIN=$(az rest --method get \
  --url "https://graph.microsoft.com/v1.0/domains" \
  --query "value[?isDefault].id" -o tsv)

echo " Revoking role from DBAdmins..."
DB_GROUP_ID=$(az ad group show --group $DB_GROUP --query id -o tsv)
RG_SCOPE="/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP"
az role assignment delete --assignee $DB_GROUP_ID --role "Reader" --scope $RG_SCOPE
echo " Role revoked."

echo " Deleting test users..."
az ad user delete --id "webadmin.test@$TENANT_DOMAIN"
az ad user delete --id "dbadmin.test@$TENANT_DOMAIN"
echo " Users deleted."

echo " Deleting AD Groups..."
az ad group delete --group $WEB_GROUP
az ad group delete --group $DB_GROUP
echo " Groups deleted."

echo "🧹 Deleting Resource Group..."
az group delete --name $RESOURCE_GROUP --yes --no-wait
echo " Resource Group deletion started."

echo " Cleanup complete!"