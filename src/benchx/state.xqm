(:~ 
 : restxq session for benchmark
 :@author Andy Bunce
 :@version 0.1
 :
 :)
module namespace s = 'apb.benchx.state';
declare default function namespace 'apb.benchx.state'; 

import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace lib='apb.benchx.library' at 'library.xqm';
import module namespace env = 'quodatum.basex.env' at 'lib.xq/basex-env.xqm';

import module namespace session = "http://basex.org/modules/session";
import module namespace sessions = "http://basex.org/modules/sessions";

declare variable $s:root:=fn:doc(fn:resolve-uri("state.xml"))/root;

declare  function benchmark() as element(benchmark)
{
    copy $s:=_benchmark()
    modify(
        replace node $s/environment with env:xml(),
        replace node $s/server with $s:root/server
    )
    return $s
};

declare %private function _benchmark() as element(benchmark)
{
  let $s:=session:get("benchmark.values")
  return if(fn:empty($s)) then $lib:new else $s
};

declare function benchmark($newValue as element(benchmark))
 as element(benchmark){
 session:set("benchmark.values",$lib:new)
};

(:~ add new result to session 
 :)
declare function add($result as element(run))
{
    let $new:=copy $d:=_benchmark()
              modify insert node $result into $d/runs
              return $d        
    return session:set("benchmark.values",$new)
};

(:~ delete session values 
 :)
declare function clear()
{
    session:delete("benchmark.values")
};

(:~
 : @return filesize of auction.xml
 :)
declare function file-size(){
    let $f:=$xm:base-dir ||"benchx-db/auction.xml"
    return if(file:exists($f)) then file:size($f) else 0
 };
 
declare function mode() as xs:string{
    if (db:exists("benchx-db")) then "D" else "F"
};

(:~ set mode to file or database
 :)
declare %updating function mode($mode as xs:string){
     switch ($mode)
        case "F" return if(db:exists("benchx-db")) 
                        then db:drop("benchx-db") else ()
        case "D" return (
                         db:create("benchx-db"
                            ,$xm:base-dir ||"benchx-db/auction.xml"
                            ,"auction.xml")
                            )
        default return ()
};

declare function factor() as xs:double{
    $s:root/state/factor/fn:number()
};

(:~ set mode to file or database
 :)
declare function factor($factor as xs:double){
    if($factor=factor())then ()
    else xm:xmlgen($factor)
};

declare %updating function make($mode as xs:string,$factor as xs:double){
    let $x:=fn:trace(($mode,$factor),"MAKE")
    let $x:=factor($factor)
    return (mode($mode),set-state($mode,$factor))
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

declare %updating function set-state($mode)
{
    set-state($mode,())
};

declare %updating function set-state($mode,$factor)
{
   let $x:= copy $d:=$s:root
            modify (replace value of node $d/state/mode with $mode,
                    replace value of node $d/state/factor with $factor
                    )
            return $d                              
   return fn:put($x,fn:base-uri($s:root))     
};

 
declare function state() as element(state)
{
<state>
        <sessions type="number">{fn:count(sessions:ids())}</sessions>
        <session>{session:id()}</session>
        <mode>{s:mode()}</mode>
        <factor>{$s:root/state/factor/fn:string()}</factor>
        <size>{prof:human(s:file-size())}</size>
         {$s:root/server/*}
    </state>
};