<#
.SYNOPSIS
  Disables Grok Build telemetry by setting persistent User environment variables.

.DESCRIPTION
  Sets four environment variables at the User level (persisted in the Windows
  registry, surviving reboots and Grok updates). Env vars override config-file
  AND remote settings, so this is the strongest user-level kill switch.

  -Show     Print current values without changing anything.
  -Remove   Delete the variables (restore defaults).

  Re-run the script any time to re-apply after a Grok update.
#>
param(
  [switch]$Show,
  [switch]$Remove
)

$vars = [ordered]@{
  'GROK_TELEMETRY_ENABLED'  = '0'
  'GROK_INSTRUMENTATION'    = 'disabled'
  'DISABLE_ERROR_REPORTING' = '1'
  'GROK_CRASH_HANDLER'      = 'false'
}

if ($Show) {
  foreach ($name in $vars.Keys) {
    $current = [Environment]::GetEnvironmentVariable($name, 'User')
    $status  = if ($null -eq $current) { '<not set>' } else { $current }
    Write-Host "  $name = $status"
  }
  exit 0
}

if ($Remove) {
  foreach ($name in $vars.Keys) {
    [Environment]::SetEnvironmentVariable($name, $null, 'User')
    Write-Host "  Removed $name"
  }
  Write-Host "`nTelemetry env vars cleared. Restart your terminal for changes to take effect."
  exit 0
}

foreach ($name in $vars.Keys) {
  $value = $vars[$name]
  [Environment]::SetEnvironmentVariable($name, $value, 'User')
  Write-Host "  Set $name = $value"
}

Write-Host "`nDone. Restart your terminal (or log out/in) for the new process to pick up these variables."
Write-Host "Verify with:  .\disable-grok-telemetry.ps1 -Show"
