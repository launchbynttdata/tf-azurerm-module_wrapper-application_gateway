After creating application gateway and web applications as backend pool for application gateway using terraform, web application code needs to be deployed. This document specifies the commands and testing guidelines for deploying and testing web application using app gateway.

We will deploy two web apps, one containing the `images` folder and second one containing the `videos` folder.

## Commands to deploy sample web applications
Replace the values of variables below with resource names of the resources created by terraform. While replacing the values for `FIRST_WEB_APP` make sure to select the value of `app service` provided in `backend_pool_images` in `app gateway`. While replacing the values for `SECOND_WEB_APP` make sure to select the value of `app service` provided in `backend_pool_videos` in `app gateway`.

Switch to `tf-azurerm-wrapper_module-application_gateway/examples/with_web_app/deployment` directory to run commands below.

RESOURCE_GROUP=launch-network-2351624540
FIRST_WEB_APP=launch-network-2794677915
SECOND_WEB_APP=launch-network-6636137170

az webapp deploy --resource-group $RESOURCE_GROUP --name $FIRST_WEB_APP --type zip --src-path web_app_one.zip

az webapp deploy --resource-group $RESOURCE_GROUP --name $SECOND_WEB_APP --type zip --src-path web_app_two.zip

## Commands to access the sample application

Using azure assigned domain name for the web apps we could test the web applications using urls below to make sure deployment wen through successfully. The `default.html` file specified name of the folder (images or videos).

**Using web application urls**
https://launch-network-2794677915.azurewebsites.net/images/default.html

https://launch-network-6636137170.azurewebsites.net/videos/default.html

**Using App gateway urls**
Using azure assigned domain name for the app gateway service we could test the web applications using urls below to make sure deployment wen through successfully. The `default.html` file specified name of the folder (images or videos).

pip-appgateway-launch-eastus2-demo.eastus2.cloudapp.azure.com/images/default.html
pip-appgateway-launch-eastus2-demo.eastus2.cloudapp.azure.com/videos/default.html

**Header Rewrite**
A header with key value `hostname=appgateway` gets added to request and response when calling url `pip-appgateway-launch-eastus2-demo.eastus2.cloudapp.azure.com/images/default.html`
This is demonstration of header rewrite functionality.
