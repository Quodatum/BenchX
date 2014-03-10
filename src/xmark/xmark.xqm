(:~ 
 :  interface for running XMark benchmark.
 :  create source file
 :  time a xmark query from file or db
 :  create database
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
 : return execution time of $xq or $timeout if no result before $timeout
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
        $timeout
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
    else db:drop("xmark")                
 };      