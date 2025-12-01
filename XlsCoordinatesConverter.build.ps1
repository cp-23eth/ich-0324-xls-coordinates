task Test {
    Write-Host "Lancement des tests..."
    $result = (Invoke-Pester -Script './XlsCoordinatesConverter.Tests.ps1' -CodeCoverage @('./XlsCoordinatesConverter.ps1') -PassThru -Quiet).Result
    if ($result -ne 'Passed') {
        throw "Certains tests ont échoué."
        break
    }
    else {
        Write-Host "Passed"
    }
}

task Lint {
    Write-Host "Analyse de la qualité du code avec PSScriptAnalyzer..."
    $results = Invoke-ScriptAnalyzer -Path './XlsCoordinatesConverter.ps1'
    $results | Group-Object -Property Severity | Select-Object Name, Count | Format-Table

    if ($results.Severity -contains 'Error') {
        throw "Des erreurs de qualité de code ont été détectées."
        break
    }
    elseif ($results.Severity -contains 'Warning') {
        Write-Host "Des avertissements de qualité de code ont été détectés."
    }
    else {
        Write-Host "Aucune erreur ou avertissement de qualité de code détectée."
    }
}

task Release {
    $psm1SourceFilePath = "./XlsCoordinatesConverter.ps1"
    $psm1DestFilePath = "./release/XlsCoordinatesConverter-eth.psm1"

    $psd1SourceFilePath = "./XlsCoordinatesConverter.psd1"
    $psd1DestFilePath = "./release/XlsCoordinatesConverter-eth.psd1"

    Mkdir "./release/XlsCoordinatesConverter-eth" -ErrorAction SilentlyContinue

    Copy-Item -Path $psm1SourceFilePath -Destination $psm1DestFilePath -Force
    Copy-Item -Path $psd1SourceFilePath -Destination $psd1DestFilePath -Force
}

task Publish {
    Write-Host "Publication du module..."
    ./Read-EnvFile -Path './.env'
    $apiKey = $env:PSGALLERY_API_KEY

    Write-Host "Clé API récupérée: $apiKey"

    if (-not $apiKey) {
        throw "La clé API PSGALLERY_API_KEY n'est pas définie dans les variables d'environnement."
    }

    Publish-Module -Path './release/XlsCoordinatesConverter-eth' -NuGetApiKey $apiKey;
}

# task . Test, Lint, Release, Publish
task . Test, Lint, Release