<#
 Usage:
  - Set desired Repo
  - Credentials will need to be provided for Jira and Bamboo.you will be prompted for each.
  - There is a "$ticketage -gt 30" (line 60); This is how many days old the ticket is and can be adjusted as needed.
 Description: Compares Bamboo Branches using Jira Ticket status and age, deletes branches based on this criteria

 #>
 
 # Sets Repository and BitBucketURL
$repo = "BlankRepoName"
$bambooURL = "https://api.bitbucket.org/2.0/repositories/dddsdev/$repo/refs/branches?pagelen=100"

# BitBucket Creditals; creates encrypted variable and then wipes memory of plain text.
$bcred = Get-Credential -message "Please enter Bitbucket credentials"
$ubcred = $bcred.GetNetworkCredential().username
$pbcred = $bcred.GetNetworkCredential().password
$byte = [System.Text.Encoding]::UTF8.GetBytes("${ubcred}:${pbcred}")
$cred = [System.Convert]::ToBase64String($byte)
$bcred = "0000"
$ubcred = "0000"
$pbcred = "0000"

# Jira Creditals; creates encrypted variable and then wipes memory of plain text.
$jcred = Get-Credential -message "Please enter Jira credentials"
$ujcred = $jcred.GetNetworkCredential().username
$pjcred = $jcred.GetNetworkCredential().password
$jirabyte = [System.Text.Encoding]::UTF8.GetBytes("${ujcred}:${pjcred}")
$jiracred = [System.Convert]::ToBase64String($jirabyte)
$jcred = "0000"
$ujcred = "0000"
$pjcred = "0000"

#Logs into Bitbucket
$issue = Invoke-WebRequest -Uri $bambooURL -Headers @{"Authorization"="Basic $cred"} -ContentType application/json | ConvertFrom-JSON

# Logic for each ticket found in Jira

foreach ($name in $issue.values.name){
	if ($name -match "feature/"){
		$issue = ($name -replace 'feature/','')
		#$name
		try{
		$jiraURL = "https://yourJira.com/rest/api/latest/issue/$issue"
		$ticket = Invoke-WebRequest -Uri $jiraURL -Headers @{"Authorization"="Basic $jiracred"} -ContentType application/json | ConvertFrom-JSON
		}catch {"Invalid branch name $name"} 


# Gets date of ticket, and compare to current date to form a value $TicketAge; this is neccessary beacuse $ticket.fields.updated not a datetime object for compare.

					$uDate = $ticket.fields.updated
					$uDate = $uDate.substring(0,10)									# Parses first 10 characters
					$uDate = [datetime]"$uDate"										#Converts to Date
					$cDate = Get-Date -format "yyyy-MM-dd"			
					$TicketAge = (NEW-TIMESPAN -Start $uDate -End $cDate).Days	

# Final work to be done to each ticket
		if ((($ticket.fields.status.name -eq "Closed") -Or ($ticket.fields.status.name -eq "Released") -And ($ticketAge -gt 30)))
   
{
			$name
			$delete = '{
				"name": "refs/heads/$name",
				"dryRun": false
			}'
			cd c:\git\$repo
			$command = "git push --delete origin feature/$issue"
			$command
			invoke-expression "& $command"
			
			
	}
}
}


