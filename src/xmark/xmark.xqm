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
declare variable $xm:base-dir:=file:parent(fn:static-base-uri());
declare variable $xm:exec:=$xm:base-dir ||$xm:bin;

(:~
 : get xmark query
 :)
declare function get-xmark($query as xs:integer
) {
  let $f:=fn:resolve-uri(
    "queries/q" || $query || ".xq"
  )
  return fn:unparsed-text($f) 
};

(:~
 : run xmark query
 :)
declare function time-xmark(
  $query as xs:integer,$timeout as xs:double
) {
  let $xq:=get-xmark($query)
  let $xq:='declare base-uri "' || fn:static-base-uri() ||'";' || $xq
  return time($xq,$timeout)
};

(:~
 : run xmark query
 :)
declare function time-xmark-all(
  $timeout as xs:double
) {
  let $res:=(1 to 20)!<query id="{.}">{time-xmark(.,fn:number($timeout))}</query>
  return <run>{$res}</run>
};
(:~
 : return execution time of $xq in ms or $timeout if no result before $timeout
 :) 
declare function time($xq as xs:string,$timeout as xs:double){
 let $bindings:=map{}
 let $opts:=map {
     "permission" := "create",
     "timeout":=$timeout
  }
  return try{
       let $t1:=prof:current-ms()
       let $x:= xquery:eval($xq,$bindings,$opts)
       return prof:current-ms()-$t1
      }catch * 
      {
        $timeout * 1000
      }
};

(:~
 : create auction.xml
 :)
declare function xmlgen($factor as xs:double){
    let $factor:=fn:string($factor)
    let $args:=if($xm:isWin)
           then ("/f",$factor,"/o",$xm:base-dir ||"xmark\auction.xml")
           else ("-f",$factor,"-o",$xm:base-dir ||"xmark/auction.xml")
    return proc:system($xm:exec,$args)
 };
 
 (:~
 : @return filesize of auction.xml
 :)
declare function file-size(){
    let $f:=$xm:base-dir ||"xmark/auction.xml"
    return if(file:exists($f)) then file:size($f) else 0
 };
 
 (:~
 : create or drop xmark db with auction.xml
 :)
declare %updating function manage-db($create as xs:boolean){
    if($create) then
        db:create("xmark"
                    ,$xm:base-dir ||"xmark/auction.xml"
                    ,"auction.xml")
    else if (db:exists("xmark"))then db:drop("xmark") else ()               
 };      