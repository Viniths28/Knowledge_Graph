# clean-json.ps1
if (-not (Test-Path 'import\parsed')) {
    New-Item -ItemType Directory -Path 'import\parsed' | Out-Null
}

Get-ChildItem -Path . -Filter '*.json' | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $jsonPos = [Array]::IndexOf($bytes, 0x7B)  # 0x7B is '{'
    if ($jsonPos -ge 0) {
        $cleanBytes = $bytes[$jsonPos..($bytes.Length-1)]
        $outPath = Join-Path 'import/parsed' $_.Name
        [System.IO.File]::WriteAllBytes($outPath, $cleanBytes)
        Write-Host "Cleaned $($_.Name) -> import/parsed"
    } else {
        Write-Warning "No JSON found in $($_.Name) - skipped"
    }
}