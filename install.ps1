if (!(test-path $profile))
{
   if (!(test-path (split-path $profile -parent)))
   {
      new-item -path (split-path $profile -parent) -ItemType Directory
   }
   else
   {
      Write-host "Profile folder exists"
   }

   new-item -path $profile -ItemType file
}
else
{
   write-host "Powershell Profile exists"
}

$pattern="#comics"
$import="import-module " + (Split-Path -parent $PSCommandPath) + "`\scripts.ps1"

if (!(Get-Content $profile | Select-String -pattern $pattern))
{
   Add-Content -path $profile -value "`n"
   Add-Content -path $profile -value $pattern
   Add-Content -path $profile -value $import
   Write-Host "Profile Updated"
}

Choco Install nodejs
npm install x-ray
