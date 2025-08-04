
Param(
  [string]$DbName = "neo4j"
)

# Load .env for image tag
$envPath = Join-Path (Get-Location) ".env"
$envVars = @{}
if (Test-Path $envPath) {
  Get-Content $envPath | ForEach-Object {
    if ($_ -and ($_ -notmatch '^\s*#') -and ($_ -match '=')) {
      $parts = $_.Split('=',2)
      $envVars[$parts[0].Trim()] = $parts[1].Trim()
    }
  }
}

$imageTag = $envVars["NEO4J_IMAGE_TAG"]
if ([string]::IsNullOrWhiteSpace($imageTag)) { $imageTag = "5.26.0" }

Write-Host "Stopping 'neo4j-dev-kg' container..."
docker compose stop neo4j-dev-kg

# Ensure backups directory exists
$bkDir = Join-Path (Get-Location) "backups"
if (!(Test-Path $bkDir)) { New-Item -ItemType Directory -Path $bkDir | Out-Null }

# Offline dump using explicit volume name
Write-Host "Running offline dump for database '$DbName' using neo4j:$imageTag ..."
docker run --rm --name neo4j-dump `
  -v neo4j_dev_kg_data:/data `
  -v "${PWD}\backups:/backups" `
  neo4j:$imageTag `
  neo4j-admin database dump $DbName --to-path=/backups

if ($LASTEXITCODE -ne 0) {
  Write-Error "Dump failed. Check that the 'neo4j_dev_kg_data' volume exists and the DB is stopped."
} else {
  Write-Host "Dump completed. Files are in ./backups"
}

Write-Host "Starting 'neo4j-dev-kg' container..."
docker compose start neo4j-dev-kg
