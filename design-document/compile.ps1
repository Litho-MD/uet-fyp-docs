$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try {
    function Invoke-Tool {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Command,
            [Parameter(Mandatory = $true)]
            [string[]]$Arguments
        )

        & $Command @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "$Command failed with exit code $LASTEXITCODE."
        }
    }

    $pumlRoot = (Resolve-Path 'diagrams/puml').Path
    Get-ChildItem -Path $pumlRoot -Filter '*.puml' -File -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($pumlRoot.Length).TrimStart('\', '/')
        $relativeDirectory = Split-Path $relative -Parent
        $outputDirectory = if ($relativeDirectory) {
            Join-Path 'Figures' $relativeDirectory
        } else {
            'Figures'
        }

        New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
        $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
        Write-Host "Generating $outputDirectory/$name.png from $relative"
        Invoke-Tool 'plantuml' @('-tpng', $_.FullName, '-o', (Join-Path $PWD $outputDirectory))
    }

    $mmdRoot = (Resolve-Path 'diagrams/mmd').Path
    Get-ChildItem -Path $mmdRoot -Filter '*.mmd' -File -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($mmdRoot.Length).TrimStart('\', '/')
        $output = Join-Path 'Figures' ([IO.Path]::ChangeExtension($relative, '.png'))
        $outputDirectory = Split-Path $output -Parent

        New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
        Write-Host "Generating $output from $relative"
        Invoke-Tool 'mmdc' @('-i', $_.FullName, '-o', $output, '-b', 'white')
    }

    Invoke-Tool 'pdflatex' @('-interaction=nonstopmode', 'uet_thesis.tex')
    Invoke-Tool 'bibtex' @('uet_thesis')
    Invoke-Tool 'pdflatex' @('-interaction=nonstopmode', 'uet_thesis.tex')
    Invoke-Tool 'pdflatex' @('-interaction=nonstopmode', 'uet_thesis.tex')
}
finally {
    Pop-Location
}
