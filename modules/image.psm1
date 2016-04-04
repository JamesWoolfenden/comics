function show-image
{
   param(
   [string]$filepath)
   
   [void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
   $file = (Get-item $filepath) 
   $img = [System.Drawing.Image]::Fromfile($file);

   [System.Windows.Forms.Application]::EnableVisualStyles();
   $form = new-object Windows.Forms.Form
   $form.Text   = $file.BaseName
   $form.Width  = $img.Size.Width  + 10;
   $form.Height =  $img.Size.Height+ 40;
   $pictureBox  = new-object Windows.Forms.PictureBox
   $pictureBox.Width  =  $img.Size.Width;
   $pictureBox.Height =  $img.Size.Height;

   $pictureBox.Image = $img;
   $form.controls.add($pictureBox)
   $form.Add_Shown( { $form.Activate() } )
   $form.ShowDialog()
}

function test-image
{
   param(
   [string]$title,
   [string]$issue)
   
   $padtitle=$title -replace(" ","-")
   $padtitle=$padtitle -replace(":","-")
   write-verbose "Test image: $issue!"
   $cover= Get-cover $issue
   $filepath= Get-imagefilename -title $title -issue $issue
   #Write-host $filepath
   test-path $filepath
}

function Get-imagefilename
{
   param(
   [string]$title,
   [string]$issue)
      
   $padtitle=$title -replace(" ","-")
   $padtitle=$padtitle -replace(":","-")
   $cover= Get-cover $issue
   $issue=$issue.Replace(":","")
   ($imageroot+"\"+$padtitle+"\"+$cover+"\"+$issue+".jpg").ToUpper()
}

function set-imagefolder
{
   param(
   [string]$title,
   [string]$issue)
   
   $cover= Get-cover $issue
   $padtitle=$title -replace(" ","-")
   $padtitle=$padtitle -replace(":","-")
   $imagefolder="$imageroot\$padtitle\$cover"
   
   if (!(test-path -path  $imagefolder))
   {
      md $imageroot\$padtitle\$cover
   }
}

function import-image 
{
   param (
   [string]$title,
   [string]$issue)

   $wherestring="where Title = '$title' And Issue = '$issue' order by PublishDate"
   $padtitle=$title -replace(" ","-")
   $cover= Get-cover $issue
   $results=Search-DB $wherestring
   foreach ($record in $results)
   {      
      if (!(test-image $title $issue))
      {
        set-imagefolder $title $issue
        
        $fileurl=$($record.Imagesrc)
        If (($fileurl -ne "") -And ($fileurl -ne $null))
        {
           Write-Host "$($record.Imagesrc)"
           $filepath=Get-imagefilename -title $title -issue $issue
           Write-Host "$filepath"
           Invoke-webRequest $fileurl -outfile $filepath
        }
        else
        {           
           continue
        }
      }
      else
      { 
         Write-Host "Image found" -foregroundcolor green
         break
      }
   }
}