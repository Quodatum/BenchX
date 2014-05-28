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
import module namespace env = 'apb.basex.env' at 'lib.xq/basex-env.xqm';

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
    case "F" return ( 
                    if (mode()="D") then db:drop("benchx-db") else (),
                    set-mode("F")
                    )
    case "D" return (
                    db:create("benchx-db"
                        ,$xm:base-dir ||"benchx-db/auction.xml"
                        ,"auction.xml"),
                    set-mode("D")
                    )
    default return ()
};

(:~
 : create or drop benchmark-db db with auction.xml
 :)
declare %updating function toggle-db(){
   mode(if(mode()="F" )then "D" else "F")               
 };      

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

declare %updating function set-factor($factor)
{
   let $x:= copy $d:=$s:root
            modify replace value of node $d/state/factor with $factor
            return $d                              
   return fn:put($x,fn:base-uri($s:root))     
};

declare %updating function set-mode($mode)
{
   let $x:= copy $d:=$s:root
            modify replace value of node $d/state/mode with $mode
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
         <hostname>{env:hostname()}</hostname>
    </state>
};