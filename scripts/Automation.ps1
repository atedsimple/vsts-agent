$AccountUrl = Get-AutomationVariable -Name 'AccountUrl'
$PoolIds = Get-AutomationVariable -Name 'PoolIds'
$Token = Get-AutomationVariable -Name 'Token'
$PoolIds = $PoolIds -split ","

$EncodedToken =[System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Token)"))
$Headers = @{authorization = "Basic $EncodedToken"}

ForEach ($PoolId in $PoolIds) {
	Write-Output "Account URL: $AccountUrl  Pool ID: $PoolId"
	$Agents = Invoke-RestMethod -uri "$($AccountUrls)/_apis/distributedtask/pools/$($PoolId)/agents?api-version=5.1" -Method Get -Headers $Headers
	$Agents.value |
		Where-Object { $_.status -eq 'offline' } |
		ForEach-Object {
			Invoke-RestMethod -uri "$($AccountUrls)/_apis/distributedtask/pools/$($PoolId)/agents/$($_.id)?api-version=5.1" -Method Delete -Headers $Headers
		}
}