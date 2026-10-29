[CmdletBinding()]
param(
  [string]$ProjectPath = (Get-Location).Path,
  [string]$OutputPath = "renders/final-4k60.mp4"
)

$project = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path
$index = Join-Path $project "index.html"
if (-not (Test-Path -LiteralPath $index -PathType Leaf)) {
  throw "No index.html found in project directory: $project"
}

if ([System.IO.Path]::IsPathRooted($OutputPath)) {
  throw "OutputPath must be relative to the project directory."
}
if ([System.IO.Path]::GetExtension($OutputPath) -ine ".mp4") {
  throw "The fixed render profile only produces MP4 files."
}

$output = [System.IO.Path]::GetFullPath((Join-Path $project $OutputPath))
$projectPrefix = $project.TrimEnd([System.IO.Path]::DirectorySeparatorChar) +
  [System.IO.Path]::DirectorySeparatorChar
if (-not $output.StartsWith($projectPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "OutputPath must stay inside the project directory."
}

$outputDirectory = Split-Path -Parent $output
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

Push-Location $project
try {
  & npx.cmd --yes hyperframes render --docker --strict --resolution 4k --fps 60 --output $output
  if ($LASTEXITCODE -ne 0) {
    throw "HyperFrames render failed with exit code $LASTEXITCODE."
  }
} finally {
  Pop-Location
}
