import-module "$root\database.ps1"

function show-image
{
   param(
   [string]$filepath)
   
   [void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
   $file = (get-item $filepath) 
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

 
#show-image "C:\comics\covers\The-Walking-Dead\127\127Diamond.jpg"

#show-image "C:\comics\covers\Sex-Criminals\5\5a.jpg"

$imageroot= "C:\comics\covers"
$padtitle=$title -replace(" ","-")

function import-image 
{
   param (
   [string]$title,
   [string]$issue)

   $wherestring="where Title = '$title' And Issue = '$issue'"
   $padtitle=$title -replace(" ","-")
   $cover= get-cover $issue
   $results=query-db $wherestring
   foreach ($record in $results)
   {
      $filepath= $imageroot+"\"+$padtitle+"\"+$cover+"\"+$issue+".jpg"
      Write-Host "filepath: $filepath"
      if (!(test-path -path $filepath))
      {
        $imagefolder="$imageroot\$padtitle\$cover"
        if (!(test-path -path  $imagefolder))
        {
           md $imageroot\$padtitle\$cover
        }
        
        $fileurl=$($record.Imagesrc)
         If (($fileurl -ne "") -And ($fileurl -ne $null))
         {
            Write-Host "$($record.Imagesrc)"
            #$webclient = New-Object System.Net.webclient
            #$userAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2;)"
            #$webclient.Headers.Add("user-agent", $userAgent)
            #$webclient.DownloadFile $fileurl, $filepath
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
#get list of issue records
#try records 
#download the assoicated image
#if sucess return
}