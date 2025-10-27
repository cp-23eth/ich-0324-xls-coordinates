Import-Module InvokeBuild

$ModuleName = "ConvertXlsCoordinates-ETH";
$ModuleVersion = "1.0.0";
$Author = "Ethan Hofstetter";
$Description = "Module pour convertir les coordonnées Excel en indices numériques.";
$ModulePath = "$PSScriptRoot/Output"

task Clean {
    Remove-Item $ModulePath -Recurse -Force -ErrorAction Ignore
    New-Item -ItemType Directory -Path $ModulePath | Out-Null
}

task CreateModuleFiles {
    $psm1Path = "$ModulePath\$ModuleName.psm1"
    $psd1Path = "$ModulePath\$ModuleName.psd1"

    # Création du .psm1
    Copy-Item "../Scripts/convertCoordinates.ps1" -Destination $psm1Path -Force

    # Création du .psd1
    New-ModuleManifest `
        -Path $psd1Path `
        -RootModule $ModulePath"\$ModuleName.psm1" `
        -Author $Author `
        -Description $Description `
        -ModuleVersion $ModuleVersion `
        -Tags 'PowerShell', 'Excel'
}

task Test {
    Write-Host "Lancement des tests..."
    $result = (Invoke-Pester -Script ../Tests/convertCoordinates.Tests.ps1 -CodeCoverage @('../Scripts/convertCoordinates.ps1') -PassThru -Quiet).Result
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
    $results = Invoke-ScriptAnalyzer -Path ../Scripts/convertCoordinates.ps1
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

task . Clean, CreateModuleFiles, Test, Lint