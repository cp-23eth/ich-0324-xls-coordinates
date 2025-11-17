param(
        [string]$Path = "$PSScriptRoot/../.env"
    )

if (-not (Test-Path $Path)) {
    Write-Warning ".env introuvable à l’emplacement $Path"
    return
}

Get-Content -Path $Path | ForEach-Object {
    if ($_ -match '^(?<key>[^=]+)=(?<value>.*)$') {
        $key = $matches['key'].Trim()
        $value = $matches['value'].Trim()
        [System.Environment]::SetEnvironmentVariable($key, $value)
    }
}