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
 : get xmark query setting base-uri
 : @param $query is suite/file.xq
 :)
declare function get-xmark($query as xs:string
) as xs:string {
  let $f:=fn:resolve-uri(
    "suite/" || $query 
  )
  let $xq:= fn:unparsed-text($f)
  return $xq 
};


(:~
 : list query file names in suite
 :)
declare function queries($suite as xs:string)
as xs:string* {
  for $f in file:list(fn:resolve-uri("suite/" || $suite),fn:false(),"*.xq")
  order by $f (: sort by number :)
  return $f
};

(:~
 : readme for suite
 :)
declare function describe($suite as xs:string)
as xs:string {
   let $f:=fn:resolve-uri("suite/" || $suite || "/readme.md" )
   return if(fn:unparsed-text-available($f)) 
            then fn:unparsed-text($f)
            else "no documentation available"
};

(:~
 : list query file names in suite
 :)
declare function list-suites() 
as xs:string*{
  for $f in file:list(fn:resolve-uri("suite/"),fn:false())
  order by $f (: sort by number :)
  return file:name($f)
};
(:~
 : run xmark query
 :)
declare function time-xmark(
  $query as xs:string,$timeout as xs:double
) {
  let $xq:=get-xmark($query)
  let $xq:= 'declare base-uri "' || fn:static-base-uri() ||'";&#10;' || $xq 
 
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
 
 