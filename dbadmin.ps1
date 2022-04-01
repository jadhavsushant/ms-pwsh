function ConvertTo-Sid {
param (
    [string]$appId
)
[guid]$guid = [System.Guid]::Parse($appId)
foreach ($byte in $guid.ToByteArray()) {
    $byteGuid += [System.String]::Format("{0:X2}", $byte)
}
return "0x" + $byteGuid
}

function ConnectAndExecuteSql {
    param
    (
        [string] $sqlServerName,
        [string] $sqlDatabaseName,
        [string] $sqlServerUID = $null,
        [string] $sqlServerPWD = $null,
        [string] $Query
    )
    
$sqlServerFQN = "$($sqlServerName).database.windows.net"
$ConnectionString = "Server=tcp:$($sqlServerFQN);Database=$sqlDatabaseName;UID=$sqlServerUID;PWD=$sqlServerPWD;Trusted_Connection=False;Encrypt=True;Connection Timeout=60;"

$Connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
$Connection.Open()
$sqlCmd = New-Object System.Data.SqlClient.SqlCommand($query, $Connection)
$sqlCmd.ExecuteNonQuery()
$Connection.Close()
}

$context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
$AzureDevOpsServicePrincipal = Get-AzADServicePrincipal -ApplicationId $Context.Account.Id

$sid = ConvertTo-Sid -appId $Context.Account.Id
$ServicePrincipalName = $AzureDevOpsServicePrincipal.DisplayName
$sqlDatabaseName = $env:SQLDATABASENAME

$Query = "IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE name ='$ServicePrincipalName')
    BEGIN
        CREATE USER [$ServicePrincipalName] WITH DEFAULT_SCHEMA=[dbo], SID = $sid, TYPE = E;
    END
    IF IS_ROLEMEMBER('db_owner','$ServicePrincipalName') = 0
    BEGIN
        ALTER ROLE db_owner ADD MEMBER [$ServicePrincipalName]
    END
    GRANT CONTROL ON DATABASE::[$sqlDatabaseName] TO [$ServicePrincipalName];"

ConnectAndExecuteSql -Query $Query -sqlServerName $env:SQLSERVERNAME -sqlDatabaseName $env:SQLDATABASENAME -sqlServerUID $env:SQLSERVERADMINLOGIN -sqlServerPWD $env:ADMINPWD
