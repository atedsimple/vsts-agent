$PoolIDs = Get-AutomationVariable -Name 'PoolIDs'
$Token = Get-AutomationVariable -Name 'Token'
$PoolIDs = $PoolIDs -split ","

$encodedtoken =[System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($Token)"))
$headers = @{authorization = "Basic $encodedtoken"}

ForEach ($PoolID in $PoolIDs) {
	Write-Output "Pool ID: $PoolID"
	$agents = Invoke-RestMethod -uri "https://dev.azure.com/modalitysystems/_apis/distributedtask/pools/$($PoolID)/agents?api-version=5.1" -Method Get -Headers $headers
	$agents.value |
		Where-Object { $_.status -eq 'offline' } |
		ForEach-Object {
			Invoke-RestMethod -uri "https://dev.azure.com/modalitysystems/_apis/distributedtask/pools/$($PoolID)/agents/$($_.id)?api-version=5.1" -Method Delete -Headers $headers
		}
}
