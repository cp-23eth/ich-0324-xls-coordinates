FROM mcr.microsoft.com/powershell:7.5-debian-bookworm

RUN pwsh -Command "Install-Module -Name Pester -Force"
RUN pwsh -Command "Install-Module -Name PSScriptAnalyzer -Force"