Write-Host "Copying daemon.json, sleep 1 min and restart docker"
Copy-Item "C:\terraform\daemon.json" -Destination "C:\ProgramData\docker\config"

Restart-Service docker

Write-Host "Pulling the ucp client images.."
docker image pull docker/ucp-agent-win:3.1.3
docker image pull docker/ucp-dsinfo-win:3.1.3

$script = [ScriptBlock]::Create((docker run --rm docker/ucp-agent-win:3.1.3 windows-script | Out-String))
Invoke-Command $script

Write-Host "Disable certificate validation in powershell"

if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()

Write-Host "Set TLS to v1.2 from 1.0"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$USERNAME=$args[1]
$PASSWORD=$args[2]
$UCP_FQDN=-join($args[0],":",$args[3])

$AUTH_TOKEN = (Invoke-RestMethod `
    -Uri "https://$UCP_FQDN/auth/login" `
    -Body "{`"username`":`"$USERNAME`",`"password`":`"$PASSWORD`"}" `
    -Method POST).auth_token


$UCP_MANAGER= (Invoke-RestMethod `
    -Uri "https://$UCP_FQDN/info" `
    -Method GET `
    -Headers @{"Accept"="application/json";"Authorization"="Bearer $AUTH_TOKEN"}).Swarm.RemoteManagers[0].Addr

$UCP_JOIN_TOKENS= (Invoke-RestMethod `
    -Uri "https://$UCP_FQDN/swarm" `
    -Method GET `
    -Headers @{"Accept"="application/json";"Authorization"="Bearer $AUTH_TOKEN"}).JoinTokens


$UCP_JOIN_TOKEN_WORKER=(Write-Output $UCP_JOIN_TOKENS).Worker

docker swarm join --token $UCP_JOIN_TOKEN_WORKER $UCP_MANAGER







