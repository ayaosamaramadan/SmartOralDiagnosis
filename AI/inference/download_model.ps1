#!/usr/bin/env pwsh
# Download model from Google Drive into this folder (AI/inference)
# Usage (PowerShell):
#   Set-Location "path\to\SmartOralDiagnosis\AI\inference"
#   .\download_model.ps1
# Or to bypass execution policy:
#   powershell -ExecutionPolicy Bypass -File .\download_model.ps1

$ErrorActionPreference = 'Stop'
$driveId = '1kZflYeDP1mb3HEJqoAT097afrWc0fS63'
$output = Join-Path $PSScriptRoot 'model.h5'
$venvDir = Join-Path $PSScriptRoot '.venv'

Write-Host "Downloading AI model to: $output"

# Ensure Python is available
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Error "Python is not found in PATH. Please install Python 3.8+ and retry."
    exit 1
}

# Create venv if not exists
if (-not (Test-Path $venvDir)) {
    Write-Host "Creating virtual environment..."
    python -m venv $venvDir
}

$pyExe = Join-Path $venvDir 'Scripts\python.exe'
$pipExe = Join-Path $venvDir 'Scripts\pip.exe'

# Use venv's pip to install gdown
Write-Host "Installing required Python package 'gdown'..."
& $pyExe -m pip install --upgrade pip | Out-Null
& $pyExe -m pip install gdown | Out-Null

# Use gdown to download by id (handles large files / confirmation)
Write-Host "Running gdown to download model from Google Drive..."
& $pyExe -m gdown --id $driveId -O $output

if (Test-Path $output) {
    $size = (Get-Item $output).Length
    Write-Host "Download complete. File saved to: $output (size: $size bytes)"
} else {
    Write-Error "Download failed - file not found after gdown run."
    exit 2
}

Write-Host 'Done. You can now run the inference service (see README or run: uvicorn app:app --reload --port 8001)'
