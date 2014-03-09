(:~
 : create auction.xml
 : xmlgen comes with a number of options to influence the output behavior:
 : -f <factor>    scaling factor of the document, float value; 0 produces the "minimal document"
 : 0.1=11.6mb, 1.0=110mb
 : -o <file>	direct output to file
 :)
declare variable $isWin:=file:dir-separator()="\";
declare variable $bin:=if($isWin) then "win32.exe" else "xmlgen";
declare variable $base-dir:=file:parent(static-base-uri());
declare variable $exec:=$base-dir ||"../bin/" ||$bin;
declare variable $factor:="1.0";

let $args:=if($isWin)
           then ("/f",$factor,"/o",$base-dir ||"auction.xml")
           else  ("-f",$factor,"-o",$base-dir ||"auction.xml")
return proc:system($exec,$args)