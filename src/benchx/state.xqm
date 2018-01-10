(:~ 
 : restxq session for benchmark
 :@author Andy Bunce
 :@copyright quodatum
 :@version 0.1
 :@licence apache 2
 :)
module namespace s = 'apb.benchx.state';
declare default function namespace 'apb.benchx.state'; 
declare namespace res="https://github.com/Quodatum/BenchX/results";

import module namespace xm='quodatum.benchx.xmlgen' at 'xmlgen.xqm';
import module namespace lib='quodatum.benchx.library' at 'library.xqm';
import module namespace env = 'quodatum.basex.env' at 'lib.xq/basex-env.xqm';

import module namespace session = "http://basex.org/modules/session";
import module namespace sessions = "http://basex.org/modules/sessions";

declare variable $s:session:="benchx.values";
declare variable $s:root:=fn:doc(fn:resolve-uri("data/benchx/state.xml"))/root;

(: list of data generators :)
declare variable $s:generators:=map{ 
    "xmlgen":   xm:set(?,fn:false()),
    "xmlgen400":xm:set(?,fn:true()),
    "-":        function($f){()}
 };

declare  function benchmark() as element(res:benchmark)
{
    copy $s:=_benchmark()
    modify(
        replace node $s/res:environment with env:xml(),
        replace node $s/res:server with $s:root/server
    )
    return $s
};

(:~
 : get session or new
 :)
declare %private function _benchmark() as element(res:benchmark)
{
  let $s:=session:get($s:session)
  return if(fn:empty($s)) then $lib:new else $s
};

(:~ save to session :)
declare function benchmark($newValue as element(res:benchmark))
 as element(res:benchmark){
 session:set($s:session,$lib:new)
};

(:~ add new result to session 
 :)
declare %updating function add($result as element(run))
{
    let $new:=copy $d:=_benchmark()
              modify insert node $result into $d/res:runs
              return $d        
    return session:set($s:session,$new)
};

(:~ delete session values 
 :)
declare function clear()
{
    session:delete($s:session)
};

(:~
 : @return filesize of auction.xml
 :)
declare function file-size(){
    let $f:=$xm:base-dir ||"benchx-db/auction"
    return if(file:exists($f)) then file:size($f) else 0
 };
 
declare function mode() as xs:string{
    if (db:exists("benchx-db")) then "D" else "F"
};

(:~
 : max time for execution of query
 :)
declare function timeout() as xs:double{
    $s:root/state/timeout
};
(:~ set mode to file or database
 :)
declare %updating function mode($mode as xs:string){
     switch ($mode)
        case "F" return if(db:exists("benchx-db")) 
                        then db:drop("benchx-db") else ()
        case "D" return (
                         db:create("benchx-db"
                            ,$xm:base-dir ||"benchx-db",
                            "",map{"createfilter":"*"})
                            )
        default return ()
};

declare function factor() as xs:double{
    $s:root/state/factor/fn:number()
};

declare function generator() as xs:string{
    $s:root/state/generator
};

(:~ set mode to file or database
 :)
declare function factor($factor as xs:double){
    if($factor=factor())then ()
    else xm:set($factor,fn:false())
};

declare %updating function make($mode as xs:string,
                                $factor as xs:double,
                                $generator as xs:string){
    let $x:=fn:trace(($mode,$factor),"MAKE")
    let $x:=$s:generators($generator)($factor)
    return (mode($mode),save-state($mode,$factor,$generator))
};



(:~ 
 : ensure guid is assigned for server
 :)
declare %updating function init()
{
   if($s:root/server/id/fn:string()) then ()
   else let $server:= <server>
                        <id>{random:uuid()}</id>
                        <hostname>{env:hostname()}</hostname>
                        <description/>
                    </server>
       let $x:= copy $d:=$s:root
                modify replace node $d/server with $server
                return $d                              
       return fn:put($x,fn:base-uri($s:root))     
};

declare %updating function save-state($mode)
{
    save-state($mode,(),"xmlgen")
};

declare %updating function save-state($mode,$factor,$generator)
{
   let $x:= copy $d:=$s:root
            modify (replace value of node $d/state/mode with $mode,
                    replace value of node $d/state/factor with $factor,
                    replace value of node $d/state/generator with $generator
                    )
            return $d                              
   return fn:put($x,fn:base-uri($s:root))     
};

 
declare function state() as element(root)
{
    copy $d:=$s:root
    modify (replace value of node $d/session/id with session:id(),
            replace value of node $d/session/sessions with fn:count(sessions:ids()),
            replace value of node $d/state/filesize with prof:human(s:file-size())
            )
    return $d      
};