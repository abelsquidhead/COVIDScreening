#!/bin/bash

# variables used in provision and configure script
SERVICE_PRINCIPAL=$2           # the name of the service principla used to log into azure
SERVICE_PRINCIPAL_TENANT=$4    # the service principal tenant
SERVICE_PRINCIPAL_SECRET=$6    # the service principal secret
RESOURCE_GROUP=$8              # the name of the resource group
APP_SERVICE_PLAN_NAME=${10}    # the name of the app service plan
APP_SERVICE_NAME=${12}         # the name of the app service
ACR_NAME=${14}                 # the name of the azure container registry
REGION=${16}                   # region


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

# create the acr resource
az acr create \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --sku Standard \
  --admin-enabled true

# authenticate the environment to acr
az acr login \
  --name $ACR_NAME

# build the docker image for the app
docker build \
  --rm \
  --pull \
  -f "./src/COVIDScreeningApi/Dockerfile" \
  -t "covidscreeningapi:latest" "."

# tag the image for acr publish
docker tag "covidscreeningapi:latest" "${ACR_NAME}.azurecr.io/covidscreeningapi:latest"

# push the image to acr
docker push "${ACR_NAME}.azurecr.io/covidscreeningapi:latest"

# create the app service plan for the app
echo "Creating app service plan"
az appservice plan create \
  --name $APP_SERVICE_PLAN_NAME \
  --resource-group $RESOURCE_GROUP \
  --is-linux
echo "Created app service plan"
echo 

# create the app service
echo "Creating app service"
az webapp create \
  --name $APP_SERVICE_NAME \
  --plan $APP_SERVICE_PLAN_NAME \
  --resource-group $RESOURCE_GROUP \
  -i "${ACR_NAME}.azurecr.io/covidscreeningapi:latest"
echo "Created app service"
echo

# get the host name for the site
swaggerHostName="https://$(az webapp show -n $APP_SERVICE_NAME -g $RESOURCE_GROUP --query hostNames --output tsv)"

# set the swagger base url config property
echo "Updating swagger base url"
az webapp config appsettings set \
  --settings SwaggerBaseUrl="${swaggerHostName}" \
  --name "$APP_SERVICE_NAME" \
  --resource-group "$RESOURCE_GROUP"
echo "Updated swagger base url"
echo