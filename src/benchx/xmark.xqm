(:~ 
 :  interface for running [XMark](http://www.xml-benchmark.org) benchmark.
 :  create source file using xmlgen, windows or unix
 :  create/drop database
 :  time an XMark query from file or db
 : @author Andy Bunce
 : @since March 2014
 :)
module namespace xm = 'apb.xmark.test';
declare default function namespace 'apb.xmark.test'; 



declare variable $xm:isWin:=file:dir-separator()="\";
declare variable $xm:bin:=if($xm:isWin) then "bin\win32.exe" else "bin/xmlgen";
(:~ path to app :)
declare variable $xm:base-dir:=file:parent(fn:static-base-uri());

declare variable $xm:exec:=$xm:base-dir ||$xm:bin;
declare variable $xm:data-dir:=$xm:base-dir ||"benchx-db";
(: if true create data in multiple files :)
declare variable $xm:slice as xs:boolean:=fn:false();



(:~
 : create auction.xml
 :)
declare function xmlgen($factor as xs:double){
    let $factor:=fn:string($factor)
    let $factor:=fn:trace($factor,"xmlgen starting:")
    let $x:=empty-dir($xm:data-dir)
    let $args:=if($xm:isWin)
           then ("/f",$factor,
                "/o",fn:concat($xm:data-dir ,"\" , if($xm:slice)then "" else "auction.xml"),
                if($xm:slice)then ("/s","400") else ()
                )
           else ("-f",$factor,
                 "-o",fn:concat($xm:base-dir ,"/" ,if($xm:slice)then "" else "auction.xml"),
                 if($xm:slice)then ("-s","400") else ()
                 )
    let $r:= proc:execute($xm:exec,$args)
    return if($r/code!="0")
           then fn:error(xs:QName('xm:xmlgen'),$r/error)
           else $r
 };

declare function empty-dir($path as xs:string){
 let $c:=file:children($path)
 return $c!file:delete(.,fn:true())
}; 
 