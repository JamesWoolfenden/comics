 gci covers -Directory| ?{!( $_.Name -clike $_.Name.ToUpper())}| % { ren $_.FullPath -NewName $_.Name.ToUpper() }
 
 
 add-type -Language CSharpVersion3 @'
     public class Helpers {
         public static bool IsNumeric(object o) {
             return o is byte  || o is short  || o is int  || o is long
                 || o is sbyte || o is ushort || o is uint || o is ulong
                 || o is float || o is double || o is decimal
                 ;
         }
     }
'@

filter isNumeric {

    [Helpers]::IsNumeric($_)
}


& C:\Users\Jim\AppData\Local\Google\Chrome\Application\chrome.exe --window-size=800,600 --window-position=580,240--chrome-frame --kiosk http://www.ebay.co.uk/itm/121430175603?
& "C:\Users\Jim\AppData\Local\Google\Chrome\Application\chrome.exe" --chrome-frame --window-size=800,600 --window-position=580,240 --app="http://www.ebay.co.uk/itm/121430175603?"