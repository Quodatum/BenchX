(:~ 
 : suite handling for benchx
 :@author Andy Bunce
 :@version 0.1
 :)
module namespace suite = 'apb.benchx.suite';
declare default function namespace 'apb.benchx.suite'; 
(:~
 : get xmark query setting base-uri
 : @param $query is suite/file.xq
 :)
declare function get-query($query as xs:string
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
declare function list() 
as xs:string*{
  for $f in file:list(fn:resolve-uri("suite/"),fn:false())
  order by $f (: sort by number :)
  return file:name($f)
};
