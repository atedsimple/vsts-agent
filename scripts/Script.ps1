param (
    $url
)

Resize-Partition -DriveLetter C -Size (Get-PartitionSupportedSize -DriveLetter C).SizeMax -ErrorAction SilentlyContinue
Set-Item WSMan:\localhost\Client\TrustedHosts -Value 'swarm-1, swarm-2, swarm-3, swarm-4, swarm-5, swarm-6, swarm-7' -Force
Set-ItemProperty -Path HKLM:\\Software\\Microsoft\\ServerManager -Name DoNotOpenServerManagerAtLogon -Value 1
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

Enable-PSRemoting -Force

if ($env:COMPUTERNAME -Match 'swarm-1') {
    if ((docker info --format '{{.Swarm.ControlAvailable}}') -Match 'false')
    {
        Write-Host "Attempting to initialise the swarm..."
        docker swarm init --default-addr-pool 10.20.0.0/16 --default-addr-pool-mask-length 26 --advertise-addr 10.0.0.11
        docker node update --label-add 2019=True $env:COMPUTERNAME
    }
}

Invoke-WebRequest $url -OutFile C:\Users\Public\Desktop\JoinSwarm.ps1