#!/bin/bash

# variables used in provision and configure script
SERVICE_PRINCIPAL=$2                    # the name of the service principal
SERVICE_PRINCIPAL_TENANT=$4             # the name of the service principal tenant
SERVICE_PRINCIPAL_SECRET=$6             # the service principal secret
RESOURCE_GROUP=$8                       # the name of the resource group
APIM_NAME=${10}                         # the name of api management
COSMOS_DB_NAME=${12}                    # the name of cosmos db
APP_SERVICE_PLAN_NAME=${14}             # the app service plan name
APP_SERVICE_NAME=${16}                  # the name of the app service
ACR_NAME=${18}                          # the name of azure container registry
REGION=${20}                            # the region
PUBLISHER_NAME=${22}                    # name of the publisher
PUBLISHER_EMAIL=${24}                   # email of the publisher

# log into Azure using service principal
echo "Logging into Azure with service principal..."
az login \
    --service-principal \
    --username $SERVICE_PRINCIPAL \
    --password $SERVICE_PRINCIPAL_SECRET \
    --tenant $SERVICE_PRINCIPAL_TENANT
echo "Done loggin into Azure"
echo

# get the connection string of the cosmos db resource
echo "Getting Cosmos DB connection string"
cosmosDbConnectionString=$(az cosmosdb keys list -n $COSMOS_DB_NAME -g $RESOURCE_GROUP --type connection-strings --query connectionStrings[0].connectionString --output tsv)
echo "Got Cosmos DB connection string"

# set the connection string in the app service
echo "Updating app service connection string"
az webapp config connection-string set \
  --connection-string-type Custom \
  --settings CosmosDbConnectionString="${cosmosDbConnectionString}" \
  --name "$APP_SERVICE_NAME" \
  --resource-group "$RESOURCE_GROUP"
echo "Updated app service connection string"
