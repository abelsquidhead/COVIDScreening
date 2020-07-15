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

# create the resource group
echo "Creating the resource group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $REGION
echo "Created resource group"
echo

# create the cosmos db resource
echo "Creating Cosmos DB instance"
az cosmosdb create \
  --name $COSMOS_DB_NAME \
  --resource-group $RESOURCE_GROUP
echo "Created Cosmos DB instance"
echo

# create the cosmos db in the cosmos db resource
echo "Creating Cosmos DB database"
az cosmosdb database create \
  --name $COSMOS_DB_NAME \
  --resource-group-name $RESOURCE_GROUP \
  --db-name "COVIDScreeningDb"
echo "Created Cosmos DB database"
echo

# create the 3 collections in the cosmos db resource we'll need
echo "Creating Cosmos DB collections for PortsOfEntry"
az cosmosdb collection create \
  --name $COSMOS_DB_NAME \
  --resource-group-name $RESOURCE_GROUP \
  --db-name "COVIDScreeningDb" \
  --collection-name "PortsOfEntry" \
  --partition-key-path "/PartitionKey"
echo "Done creating cosmos db collections for Ports of Entry"
echo

echo "Creating Cosmos DB collections for Representatives"
az cosmosdb collection create \
  --name $COSMOS_DB_NAME \
  --resource-group-name $RESOURCE_GROUP \
  --db-name "COVIDScreeningDb" \
  --collection-name "Representatives" \
  --partition-key-path "/PartitionKey"
echo "Done creating cosmos db collections for Representatives"
echo

echo "Creating Cosmos DB collections for Screenings"
az cosmosdb collection create \
  --name $COSMOS_DB_NAME \
  --resource-group-name $resourceGroup \
  --db-name "COVIDScreeningDb" \
  --collection-name "Screenings" \
  --partition-key-path "/PartitionKey"
echo "Done creating cosmos db collections for Representatives"
echo