# PowerShell script to build and run WebPageTest using Podman

$ImageName = "webpagetest"
$ContainerName = "webpagetest-server"

Write-Host "`n--- WebPageTest Podman Automation ---" -ForegroundColor Blue

# 1. Cleanup existing container
Write-Host "`n[1/3] Checking for existing container '$ContainerName'..." -ForegroundColor Cyan
$existing = podman ps -a --filter "name=$ContainerName" --format "{{.ID}}"
if ($existing) {
    Write-Host "Found existing container. Stopping and removing..." -ForegroundColor Yellow
    podman stop $ContainerName
    podman rm $ContainerName
} else {
    Write-Host "No existing container found."
}

# 2. Build the image
Write-Host "`n[2/3] Building Podman image '$ImageName'..." -ForegroundColor Cyan
podman build -t $ImageName .

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nError: Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 3. Run the container
Write-Host "`n[3/3] Running container '$ContainerName'..." -ForegroundColor Cyan
podman run -d --name $ContainerName -p 80:80 -p 443:443 $ImageName

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSuccess! WebPageTest is now starting up." -ForegroundColor Green
    Write-Host "Access it at: http://localhost" -ForegroundColor Green
    Write-Host "`nTo view logs: podman logs -f $ContainerName" -ForegroundColor Gray
} else {
    Write-Host "`nError: Failed to start container!" -ForegroundColor Red
    exit $LASTEXITCODE
}
