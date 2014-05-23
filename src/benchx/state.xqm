(:~ 
 : restxq session for benchmark
 :
 :)
module namespace s = 'apb.benchx.state';
declare default function namespace 'apb.benchx.state'; 

import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace lib='apb.benchx.library' at 'library.xqm';
import module namespace env = 'apb.basex.env' at 'lib.xq/basex-env.xqm';

import module namespace session = "http://basex.org/modules/session";
import module namespace sessions = "http://basex.org/modules/sessions";



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

declare function state() as element(state)
{
<state>
        <sessions type="number">{fn:count(sessions:ids())}</sessions>
        <session>{session:id()}</session>
        <mode>{xm:mode()}</mode>
        <factor>{$xm:factor/fn:string()}</factor>
        <size>{prof:human(xm:file-size())}</size>
         <hostname>{env:hostname()}</hostname>
    </state>
};