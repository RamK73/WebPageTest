# deploy-wpt.ps1
# A single script to build and run the WebPageTest Server and Multi-Browser Agents using Podman

$ServerImage = "webpagetest-server"
$AgentImage = "webpagetest-agent-multi"
$ServerContainerName = "wpt-server"
$Browsers = @("Chrome", "Firefox", "Edge")
$ServerUrl = "http://host.containers.internal/work/"

Write-Host "`n==============================================" -ForegroundColor DarkCyan
Write-Host "   WebPageTest Podman Deployment Script" -ForegroundColor Cyan
Write-Host "==============================================`n" -ForegroundColor DarkCyan

# 0. Check if Podman is running
Write-Host "[*] Checking Podman status..." -ForegroundColor Gray
podman version > $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Podman is not running or not installed!" -ForegroundColor Red
    exit 1
}

# 1. Cleanup existing containers
Write-Host "[1/4] Cleaning up existing WebPageTest containers..." -ForegroundColor Cyan
$ExistingContainers = @($ServerContainerName)
foreach ($B in $Browsers) { $ExistingContainers += "wpt-agent-$($B.ToLower())" }

foreach ($C in $ExistingContainers) {
    $id = podman ps -a --filter "name=$C" --format "{{.ID}}"
    if ($id) {
        Write-Host "  -> Stopping and removing $C ($id)" -ForegroundColor Yellow
        podman stop $C > $null
        podman rm $C > $null
    }
}

# 2. Build Images
Write-Host "`n[2/4] Building Images (this may take a while)..." -ForegroundColor Cyan

Write-Host "  -> Building Server Image ($ServerImage)..." -ForegroundColor Gray
podman build -t $ServerImage .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build Server image!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "  -> Building Agent Image ($AgentImage)..." -ForegroundColor Gray
podman build -t $AgentImage -f docker/local/Dockerfile-wptagent .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build Agent image!" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 3. Run Server
Write-Host "`n[3/4] Starting WebPageTest Server..." -ForegroundColor Cyan
$ProjectDir = (Get-Item .).FullName.Replace("\", "/")

# Ensure results directory exists
if (!(Test-Path "www/results")) {
    New-Item -ItemType Directory -Path "www/results" -Force > $null
}

podman run -d `
    --name $ServerContainerName `
    --restart unless-stopped `
    -p 80:80 -p 443:443 `
    -v "${ProjectDir}/www/results:/var/www/www/results" `
    $ServerImage

if ($LASTEXITCODE -eq 0) {
    Write-Host "  -> Server started successfully on http://localhost" -ForegroundColor Green
}
else {
    Write-Host "Error: Failed to start Server!" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 4. Run Agents
Write-Host "`n[4/4] Starting Agents for: $($Browsers -join ', ')..." -ForegroundColor Cyan

foreach ($Browser in $Browsers) {
    $AgentName = "wpt-agent-$($Browser.ToLower())"
    Write-Host "  -> Starting $AgentName..." -ForegroundColor Gray
    
    podman run -d `
        --name $AgentName `
        --restart unless-stopped `
        --shm-size=2g `
        --add-host=host.containers.internal:host-gateway `
        -e "SERVER_URL=$ServerUrl" `
        -e "LOCATION=$Browser" `
        -e "NAME=LocalAgent-$Browser" `
        -e "EXTRA_ARGS=--shaper none" `
        $AgentImage > $null
}

Write-Host "`n==============================================" -ForegroundColor DarkCyan
Write-Host "   Deployment Complete!" -ForegroundColor Green
Write-Host "   Server: http://localhost" -ForegroundColor Green
Write-Host "   Agents: Multi-browser (Chrome, Firefox, Edge)" -ForegroundColor Green
Write-Host "==============================================`n" -ForegroundColor DarkCyan
Write-Host "To view logs, use: podman logs -f $ServerContainerName" -ForegroundColor Gray
