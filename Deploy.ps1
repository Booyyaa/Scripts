<#
 Scriptname: Deploy.ps1
 Usage: .\DeployMRR.ps1 -product -env
 Description: Deploy Contoso
#>

param (
	[string]$product,
	[string]$env
)

[xml]$dest = Get-Content ".\env.xml"
$servers = $dest.product.$product.$env
$clients = $servers.client
function Deploy {
	"Deploying $zip to" + " " + "$($client)" + " " + $fqdn + " " + $loc
	Invoke-Command -ComputerName  $fqdn -Scriptblock  { param ($zip,$loc)$command = C:\"Program Files"\7-Zip\7z.exe x "c:\releases\$zip" -o"d:\$loc" -aoa} -argumentList $zip,$loc
	}

foreach ($server in $servers){
	$loc = $server.fqdn
	robocopy .\ \\$loc\c$\releases\ *.zip #Copy Zips
	}
	foreach ($server in $servers){
		foreach ($client in $server.client){
			foreach ($app in $client.app){
			$loc = $app.site 
			$zip = $app.zip
			Deploy
			}
		}
	}

