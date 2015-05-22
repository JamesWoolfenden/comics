
function set-Response
{
   param($request, $response)
    try
    {
       Write-Host "$(Get-date) - $($request.Url)"
       switch($request.RawUrl)
       {
          '/comics'
          {
             # response to http://localhost:8000/comics
             $response.ContentType = 'text/plain'
             $message = [System.DateTime]::Now.ToString()
          }
          '/date/xml'
          {
              $response.ContentType = 'text/xml'
              $hour = [System.DateTime]::Now.Hour
              $minute = [System.DateTime]::Now.Minute
              $message = "<?xml version=""1.0""?><Time><Hour>$hour</Hour><Minute>$minute</Minute></Time>"
          }
          '/date/json'
          {
              $response.ContentType = 'application/json'
              $time = '' | select hour, minute, Second
              $time.hour = [System.DateTime]::Now.Hour
              $time.minute = [System.DateTime]::Now.Minute
              $time.second=[System.DateTime]::Now.Second
              $message = $time | ConvertTo-Json
          }
          '/end'
          {
             break
          }
          default
          {
           # response to http://localhost:8000/comics
             $response.ContentType = 'text/plain'
             $message = "Endpoint Not found"
          }
       }
    }
    catch
    {
      write-error "something went bad"
      throw $_
    }
    
    [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
    $response.ContentLength64 = $buffer.length
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8000/') # Must exactly match the netsh command above
$listener.Start()

Write-host "Listening ... " -ForegroundColor Cyan
try{
while ($true) 
{
    $context = $listener.GetContext() # blocks until request is received
    $request = $context.Request
    $response = $context.Response
    
    set-Response -request $request -response $response

   }
}
catch
{
  Write-Error "Server failure"
}
finally
{
   Write-Error "Finally?"
   $listener.Stop()
}

$listener.Stop()
