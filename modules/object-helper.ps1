function Test-Property
{
  param(
  [Object]$Object,
  [string]$property)
  try
  {
     [bool]($Object.PSobject.Properties.name -match $property)
  }
  catch
  {
     $false
  }
}

function Test-ID
{
  param(
  $ie,
  [string]$id)
  try
  {
     $ie[1].Document.getElementByID($id)
     $true
  }
  catch
  {
     $false
  }
}
