if ($env:COMPUTERNAME -Match 'swarm-1') {
    if ((docker info --format '{{.Swarm.ControlAvailable}}') -Match 'false')
    {
        Write-Host "Attempting to initialise the swarm..."
        docker swarm init --default-addr-pool 10.20.0.0/16 --default-addr-pool-mask-length 26 --advertise-addr 10.0.0.11
        docker node update --label-add 2019=True $env:COMPUTERNAME
    } else {
        Write-Host "Node already part of the swarm"
    }
}

if ($env:COMPUTERNAME -NotMatch 'swarm-1') {
    if ((docker info --format '{{.Swarm.ControlAvailable}}') -Match 'false')
    {
        Write-Host "Attempting to join the swarm..."
        $token = Invoke-Command -ComputerName swarm-1 -ScriptBlock { if ((docker info --format '{{.Swarm.ControlAvailable}}') -Match 'true') { docker swarm join-token manager --quiet } }
        if ($token) {
            docker swarm join --token $token 10.0.0.11:2377
            docker node update --label-add 2019=True $env:COMPUTERNAME
        }
    } else {
        Write-Host "Node already part of the swarm"
    }
}
Pause