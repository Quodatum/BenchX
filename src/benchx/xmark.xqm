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
 : @param $query is suite/file.xq
 :)
declare function get-xmark($query as xs:string
) {
  let $f:=fn:resolve-uri(
    "suite/" || $query 
  )
  return fn:unparsed-text($f) 
};


(:~
 : list query file names
 :)
declare function list-tests($dir as xs:string) {
  for $f in file:list(fn:resolve-uri("suite/" || $dir),fn:false(),"*.xq")
  order by $f (: sort by number :)
  return $f
};

(:~
 : run xmark query
 :)
declare function time-xmark(
  $query as xs:string,$timeout as xs:double
) {
  let $xq:=get-xmark($query)
  let $xq:='declare base-uri "' || fn:static-base-uri() ||'";' || $xq
  let $res:= time($xq,$timeout)
  return (<runtime type="number">{$res[1]}</runtime>,
         <status>{$res[2]}</status>)
};


(:~
 : @param $xq xquery to evaluate 
 : @param $timeout stop execution after this time in seconds
 : @return two item sequence(execution time of $xq ,error code or "")
 :) 
declare function time($xq as xs:string,$timeout as xs:double)
as item()*{
 let $bindings:=map{}
 let $opts:=map {
     "permission" := "create",
     "timeout":=$timeout
  }
  return try{
       let $t1:=prof:current-ms()
       let $x:= xquery:eval($xq,$bindings,$opts)
       let $t:=(prof:current-ms()-$t1) div 1000
       return ($t,"")
      }catch * 
      {
        ($timeout ,$err:code)
      }
};


(:~
 : create auction.xml
 :)
declare function xmlgen($factor as xs:double){
    let $factor:=fn:string($factor)
    let $factor:=fn:trace($factor,"xmlgen starting:")
    let $args:=if($xm:isWin)
           then ("/f",$factor,"/o",$xm:base-dir ||"benchx-db\auction.xml")
           else ("-f",$factor,"-o",$xm:base-dir ||"benchx-db/auction.xml")
    let $r:= proc:execute($xm:exec,$args)
    return if($r/code!="0")
           then fn:error(xs:QName('xm:xmlgen'),$r/error)
           else $r
 };
 
 