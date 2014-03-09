(:~ 
 :  interface for running XMark benchmark
 :
 :)
module namespace xm = 'apb.xmark.test';
declare default function namespace 'apb.xmark.test'; 

declare variable $xm:isWin:=file:dir-separator()="\";
declare variable $xm:bin:=if($xm:isWin) then "bin\win32.exe" else "bin/xmlgen";
declare variable $xm:base-dir:=file:parent(fn:static-base-uri());
declare variable $xm:exec:=$xm:base-dir ||$xm:bin;

(:~
 : run xmark query
 :)
declare function time-xmark(
  $query as xs:integer,$timeout as xs:double
) {
  let $f:=fn:resolve-uri(
    "queries/q" || $query || ".xq"
  )
  let $xq:=fn:unparsed-text(
    $f
  )
  let $xq:='declare base-uri "' || fn:static-base-uri() ||'";' || $xq
  return time($xq,10)
};

(:~
 : return execution time of $xq or $timeout if no result before result
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
declare function create($factor as xs:double){
    let $factor:=fn:string($factor)
    let $args:=if($xm:isWin)
           then ("/f",$factor,"/o",$xm:base-dir ||"auction.xml")
           else  ("-f",$factor,"-o",$xm:base-dir ||"auction.xml")
    return proc:system($xm:exec,$args)
 };   