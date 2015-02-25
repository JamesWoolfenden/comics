function get-coverselection
{
  <#
      .SYNOPSIS 
       form function to pass selected title
        
   #>
  param(
  [Parameter(Mandatory=$true)]
  [string]$selection)

  $script:Choice=$selection 
  $Form.Dispose()
}

function get-imagetitle
{
  <#
      .SYNOPSIS 
       Call to select title from similar issues cover, useful for variants.
        
      .EXAMPLE
      C:\PS> get-imagetitle -title CHEW -issue 1
      This displays a dilaog with a number of possible no.1 covers for the title chew.
   #>
   param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$issue)

   [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
   [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
   
   $script:Choice=$null
   $imagepath="$PSScriptRoot\covers\"
   $padtitle=$title -replace(" ","-")
   $scanpath=$imagepath+$padtitle+"\$issue\"
   
   if (!(test-path $scanpath))
   {
      Write-Host "Not in Library, Add(y)?" -foregroundcolor yellow -nonewline
      $add=read-host
      if ($add -eq "y")
      {
         return $issue
      }
      else
      {
         return $null
      }
   }

   Write-debug "Scan path: $scanpath" 
   $coverfiles=gci -path $scanpath

   #Draw form
   $Form                   = New-Object System.Windows.Forms.Form
   
   $ToolTip                = New-Object System.Windows.Forms.ToolTip
   $ToolTip.AutomaticDelay = 0

   [System.Windows.Forms.Application]::EnableVisualStyles();
   $counter=1
   $y=1  
   $x=1

   foreach($imgfile in $coverfiles)
   {    
      $file = (get-item $imgfile.FullName) 
      $img = [System.Drawing.Image]::Fromfile($file);
      $obj= new-object System.Windows.Forms.Button
      $obj.Location = new-object System.Drawing.Size($x,$y)
      $obj.BackgroundImage=$img
      $width=$img.Size.Width
      $Height=$img.Size.Height
      $obj.Size = new-object System.Drawing.Size($Width,$Height)
      $obj.Name=$imgfile.BaseName
   
      $obj.Add_MouseHover({$obj.backcolor = [System.Drawing.Color]::Azure})
      $obj.Add_MouseLeave({$obj.backcolor = [System.Drawing.Color]::CornflowerBlue})
      $ToolTip.SetToolTip($obj,$imgfile.BaseName )
      $obj.Add_Click({get-coverselection $($obj.Name)}.GetNewClosure())
      $Form.Controls.Add($obj)
      $x=$x+$img.Size.Width+10
      $counter++
      $maxheight=(0,$Height | Measure -Max).Maximum
   }

   $Form.width          = $x+10
   $Form.height         = $maxheight+45
   $Form.Top            = 1000
   $Form.Left           = 0
   $Form.backcolor      = [System.Drawing.Color]::Black
   $Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
   $Form.Text           = "Cover selector"
   $Form.Font           = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
   $Form.maximumsize    = New-Object System.Drawing.Size($Form.width,260)
   $form.HorizontalScroll.Visible=$true
   $form.AutoScroll = $True

   $Form.KeyPreview    = $True
   $Form.Add_KeyDown({if ($_.KeyCode -eq "Enter") {}})
   $Form.Add_KeyDown({
      if ($_.KeyCode -eq "Escape") 
      {
         $Form.Close()
      }
   })
     
   $Form.Add_Shown({$Form.Activate()})
  
   $result=$Form.ShowDialog()
   if (($choice -eq $NULL) -or ($choice -eq ""))
   {
      $choice=read-host "Set Issue title"  
   }
   
   write-debug $choice 
   $choice
}

function get-image
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$issue)
   
   Write-debug "Looking for $issue"

   if (test-image -title $title -issue $issue)
   {
      $color="green"
   }
   else 
   {
      $color="red"   
   } 
     
   $color
}
