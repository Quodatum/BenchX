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

declare variable $s:root:=db:open("benchx","state.xml")/root;
declare variable $s:factor:=$s:root/state/factor;
declare variable $s:mode:=$s:root/state/mode;
declare variable $s:server:=$s:root/server;

declare function benchmark() as element(benchmark)
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
    let $new:=copy $d:=benchmark()
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

 (:~
 : create or drop xmark db with auction.xml
 :)
declare %updating function manage-db($create as xs:boolean){
    if($create) then
        db:create("benchx-db"
                    ,$xm:base-dir ||"benchx-db/auction.xml"
                    ,"auction.xml")
    else if (mode()="D") then db:drop("benchx-db") else ()               
 }; 
 
(:~
 : create or drop benchmark-db db with auction.xml
 :)
declare %updating function toggle-db(){
   manage-db(mode()="F")               
 };      

(:~ get server data
:) 
declare function server() as element(server) 
{
    if($s:server/id/fn:string()) then $s:server 
    else 
    <server>
        <id>{random:uuid()}</id>
        <hostname>{env:hostname()}</hostname>
        <description/>
    </server>
}; 
 (:~
 : update server data
 :)
declare %updating function server($server as element(server))
{
    if($s:server/id eq $server/id) then () 
    else replace node $s:server with $server             
 }; 
 
declare function state() as element(state)
{
<state>
        <sessions type="number">{fn:count(sessions:ids())}</sessions>
        <session>{session:id()}</session>
        <mode>{s:mode()}</mode>
        <factor>{$s:factor/fn:string()}</factor>
        <size>{prof:human(s:file-size())}</size>
         <hostname>{env:hostname()}</hostname>
    </state>
};