# PowerShell script to build and run WebPageTest Agents using Podman

$ImageName = "webpagetest-agent-multi"
$ServerUrl = "http://host.containers.internal/work/"
$Browsers = @("Chrome", "Firefox", "Edge")

Write-Host "`n--- WebPageTest Multi-Browser Agent Podman Automation ---" -ForegroundColor Blue

# 1. Build the multi-browser image
Write-Host "`n[1/2] Building Podman image '$ImageName'..." -ForegroundColor Cyan
Write-Host "This will install Chrome, Firefox, and Edge. Please wait..." -ForegroundColor Gray
podman build -t $ImageName -f docker/local/Dockerfile-wptagent .

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nError: Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 2. Run containers for each browser
Write-Host "`n[2/2] Starting agent containers..." -ForegroundColor Cyan

foreach ($Browser in $Browsers) {
    $ContainerName = "wpt-agent-$($Browser.ToLower())"
    
    # Cleanup existing
    $existing = podman ps -a --filter "name=$ContainerName" --format "{{.ID}}"
    if ($existing) {
        Write-Host "Stopping and removing existing '$ContainerName'..." -ForegroundColor Yellow
        podman stop $ContainerName
        podman rm $ContainerName
    }

    Write-Host "Starting container '$ContainerName' for location '$Browser'..." -ForegroundColor Green
    
    podman run -d `
        --name $ContainerName `
        --restart unless-stopped `
        --shm-size=2g `
        --add-host=host.containers.internal:host-gateway `
        -e "SERVER_URL=$ServerUrl" `
        -e "LOCATION=$Browser" `
        -e "NAME=LocalAgent-$Browser" `
        -e "EXTRA_ARGS=--shaper none" `
        $ImageName
}

Write-Host "`nSuccess! All agents are starting up." -ForegroundColor Green
Write-Host "They will poll '$ServerUrl' for jobs." -ForegroundColor Green
Write-Host "`nTo view Firefox logs: podman logs -f wpt-agent-firefox" -ForegroundColor Gray
Write-Host "To view Edge logs: podman logs -f wpt-agent-edge" -ForegroundColor Gray
