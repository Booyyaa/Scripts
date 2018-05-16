Function Config {

		## Output server name and client for debug purposes
		$server.name + " " + $name
			foreach($key in $clientsettings.env.$name.appSettings.add.key){
				## Output key and output file for debug purposes
				$key + " " + $path
				## Get the key value in the client specific configuration and replace the template value
				($template.configuration.appSettings.add | where {$_.key -eq $key}).Value = ($clientsettings.env.$name.appSettings.add | where {$_.key -eq $key}).Value
			}
			#foreach($key in $clientsettings.env.$client['system.serviceModel'].client.endpoint.contract){
			#	($template.configuration['system.serviceModel'].client.endpoint | where {$_.contract -eq $key}).address
			#	($clientsettings.env.$name['system.serviceModel'].client.endpoint | where {$_.contract -eq $key}).address
			#}
			## Save the result to the output path
			$template.Save($path)
		}