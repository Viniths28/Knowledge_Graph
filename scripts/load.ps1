
Param(
  [string]$DbName = "neo4j",
  [Parameter(Mandatory=$true)][string]$DumpFile
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

# Validate dump file exists under backups
$dumpPath = Join-Path (Get-Location) "backups\$DumpFile"
if (!(Test-Path $dumpPath)) {
  Write-Error "Dump file not found: $dumpPath"
  exit 1
}

Write-Host "Stopping 'neo4j-dev-kg' container..."
docker compose stop neo4j-dev-kg

# Load dump offline (overwrite current DB)
Write-Host "Loading dump '$DumpFile' into database '$DbName' using neo4j:$imageTag ..."
docker run --rm --name neo4j-load `
  -v neo4j_dev_kg_data:/data `
  -v "${PWD}\backups:/backups" `
  neo4j:$imageTag `
  bash -lc "rm -rf /data/databases/$DbName /data/transactions/$DbName && neo4j-admin database load $DbName --from-path=/backups --overwrite-destination"

if ($LASTEXITCODE -ne 0) {
  Write-Error "Load failed. Ensure the 'neo4j_dev_kg_data' volume exists and the dump file is valid."
} else {
  Write-Host "Load completed. Start the DB and verify."
}

Write-Host "Starting 'neo4j-dev-kg' container..."
docker compose start neo4j-dev-kg
