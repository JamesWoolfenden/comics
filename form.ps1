[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null


$imagepath="C:\comics\covers\"
$title="Ghosted"
$issue="1"
$scanpath=$imagepath+$title+"\$issue\"
Write-host "Scan path: $scanpath" 
$coverfiles=gci -path $scanpath

Function Map1
{
  param([string]$selection)
  Write-Host "$selection"
  $Form.Dispose()
}

#Draw form
$Form = New-Object System.Windows.Forms.Form
$Form.width         = 250
$Form.height        = 178
$Form.backcolor     = [System.Drawing.Color]::CornflowerBlue
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
$Form.Text          = "Wincapp"
$Form.Font          = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
$Form.maximumsize   = New-Object System.Drawing.Size(250,178)
$Form.startposition = "centerscreen"
$Form.KeyPreview    = $True
$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter") {}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
{
   $Form.Close()}}
)



$file = (get-item $coverfiles[0].FullName) 
$img = [System.Drawing.Image]::Fromfile($file);
[System.Windows.Forms.Application]::EnableVisualStyles();

#Draw buttons 
$Button1 = new-object System.Windows.Forms.Button
$Button1.Location = new-object System.Drawing.Size(1,1)
$Button1.BackgroundImage=$img
$width=$img.Size.Width
$Height=$img.Size.Height
$Button1.Size = new-object System.Drawing.Size($Width,$Height)
$Button1.Text =$img.BaseName
$Button1.Add_MouseHover({$Button1.backcolor = [System.Drawing.Color]::Azure})
$Button1.Add_MouseLeave({$Button1.backcolor = [System.Drawing.Color]::CornflowerBlue})
$Button1.Add_Click({Map1 "Button1"})

<#
$Button2 = new-object System.Windows.Forms.Button
$Button2.Location = new-object System.Drawing.Size(82,1)
$Button2.Size = new-object System.Drawing.Size(80,74)
$Button2.Text = "Button2"
$Button2.Add_MouseHover({$Button2.backcolor = [System.Drawing.Color]::Azure})
$Button2.Add_MouseLeave({$Button2.backcolor = [System.Drawing.Color]::CornflowerBlue})
$Button2.Add_Click({Map1 "Button2"})

$Button3 = new-object System.Windows.Forms.Button
$Button3.Location = new-object System.Drawing.Size(1,76)
$Button3.Size = new-object System.Drawing.Size(80,74)
$Button3.Text = "Button3"
$Button3.Add_MouseHover({$Button3.backcolor = [System.Drawing.Color]::Azure})
$Button3.Add_MouseLeave({$Button3.backcolor = [System.Drawing.Color]::CornflowerBlue})
$Button3.Add_Click({Map1 "Button3"})

$Button4 = new-object System.Windows.Forms.Button
$Button4.Location = new-object System.Drawing.Size(82,76)
$Button4.Size = new-object System.Drawing.Size(80,74)
$Button4.Text = "Button4"
$Button4.Add_MouseHover({$Button4.backcolor = [System.Drawing.Color]::Azure})
$Button4.Add_MouseLeave({$Button4.backcolor = [System.Drawing.Color]::CornflowerBlue})
$Button4.Add_Click({Map1 "Button4"})

$Button5 = new-object System.Windows.Forms.Button
$Button5.Location = new-object System.Drawing.Size(163,1)
$Button5.Size = new-object System.Drawing.Size(80,76)
$Button5.Text = "Button5"
$Button5.Add_MouseHover({$Button5.backcolor = [System.Drawing.Color]::Azure})
$Button5.Add_MouseLeave({$Button5.backcolor = [System.Drawing.Color]::CornflowerBlue})
$Button5.Add_Click({Map1 "Button5"})
#>
#Add them to form and active it
$Form.Controls.Add($Button1)
#$Form.Controls.Add($Button2)
#$Form.Controls.Add($Button3)
#$Form.Controls.Add($Button4)
#$Form.Controls.Add($Button5)
$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()

