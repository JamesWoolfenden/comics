Function Chooser
{
  param([string]$selection)
  #write-host $selection
  $script:Choice=$selection 
  $Form.Dispose()
}

function get-imagetitle
{
   param
   ($title="PETER-PANZERFAUST",
   $issue="1"
   )

   [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
   [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

   $imagepath="C:\comics\covers\"
   $padtitle=$title -replace(" ","-")
   $scanpath=$imagepath+$padtitle+"\$issue\"
   if (!(test-path $scanpath))
   {
      Write-Host "Not in Library, Add?" -foregroundcolor yellow -nonewline
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

   Write-host "Scan path: $scanpath" 
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
      $obj.Add_Click({Chooser $($obj.Name)}.GetNewClosure())
      $Form.Controls.Add($obj)
      $x=$x+$img.Size.Width+10
      $counter++
      $maxheight=($maxheight,$Height | Measure -Max).Maximum
   }

   $Form.width         = $x+10
   $Form.height        = $maxheight+45
   $Form.Top           = 1000
   $Form.Left          = 0
   $Form.backcolor     = [System.Drawing.Color]::CornflowerBlue
   $Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
   $Form.Text          = "Cover Chooser"
   $Form.Font          = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
   $Form.maximumsize   = New-Object System.Drawing.Size($Form.width,250)
   #$Form.startposition = "centerscreen"
   $Form.KeyPreview    = $True
   $Form.Add_KeyDown({if ($_.KeyCode -eq "Enter") {}})
   $Form.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
   {
     $Form.Close()}}
   )
   
   
   $Form.Add_Shown({$Form.Activate()})
  
   $result=$Form.ShowDialog()
   if (($choice -eq $NULL) -or ($choice -eq ""))
   {
      $choice=read-host "Set Issue title"  
   }
   
   write-host $choice 
 
 $choice
}


function found-image
{
   param(
   [string]$title,
   [string]$issue)
   
   if (test-image -title $title -issue $Issue)
   {
      $color="green"
   }
   else 
   {
      $color="red"   
   }   
   $color
}

