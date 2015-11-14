$service=get-service -Name 'WinRM'
if ($service.Status -ne "Running")
{
  $service.Start()
}

Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048
Set-Item .\microsoft.powershell\Quotas\MaxConcurrentCommandsPerShell 2048
Restart-Service WinRM
