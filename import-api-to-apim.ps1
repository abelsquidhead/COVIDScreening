Param(
    [parameter(Mandatory=$true)][string]$spName,
    [parameter(Mandatory=$true)][string]$spTenant,
    [parameter(Mandatory=$true)][string]$spSecret,
    [parameter(Mandatory=$true)][string]$ResourceGroupName,
    [parameter(Mandatory=$true)][string]$ApimInstance,
    [parameter(Mandatory=$true)][string]$ApiId,
    [parameter(Mandatory=$true)][string]$ServiceUrl,
    [parameter(Mandatory=$true)][string]$ApiVersion,
    [parameter(Mandatory=$true)][string]$SwaggerFilePath
)

# Log into azure using service principal
Write-Output "Logging into Azure with Service Principal"
[SecureString]$spPassword = $spSecret | ConvertTo-SecureString -AsPlainText -Force 
[PSCredential]$myCred = New-Object System.Management.Automation.PSCredential -ArgumentList $spName, $spPassword
Connect-AzAccount -ServicePrincipal -Credential $myCred -TenantId $spTenant       

# import the api
Write-Output "Setting API Management Context"
$ApiMgmtContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ApimInstance

# remove the old api
Write-Output "Removing the old API"
Remove-AzApiManagementApi -Context $ApiMgmtContext -ApiId $ApiId

# import the new api
Write-Output "Importing Swagger into a new API"
Import-AzApiManagementApi -Context $ApiMgmtContext -ApiId $ApiId -ServiceUrl $ServiceUrl -SpecificationFormat "Swagger" -SpecificationPath $SwaggerFilePath -Path $ApiVersion

# get the api
$api = Get-AzApiManagementApi -Context $ApiMgmtContext -ApiId $ApiId

# disable the subscription requirement
Write-Output "Disabling the subscription header requirement" 
$api.SubscriptionRequired = $false
Set-AzApiManagementApi -InputObject $api