(:~ 
 : restxq session for benchmark
 :
 :)
module namespace s = 'apb.benchmark.state';
declare default function namespace 'apb.benchmark.state'; 

import module namespace xm='apb.xmark.test' at 'xmark.xqm';

import module namespace session = "http://basex.org/modules/session";
import module namespace sessions = "http://basex.org/modules/sessions";

(:~
 : get library doc query
 :)
declare variable $s:new as element(benchmark)
             :=db:open("benchmark","benchmark.xml")/benchmark;

declare function benchmark() as element(benchmark)
{
  let $s:=session:get("benchmark.values")
  return if(fn:empty($s)) then $s:new else $s
};

declare function benchmark($newValue as element(benchmark))
 as element(benchmark){
 session:set("benchmark.values",$s:new)
};

declare function add($result as element(run))
{
    let $new:=copy $d:=benchmark()
              modify insert node $result into $d/runs
              return $d
     let $new:=fn:trace($new,"---")         
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
    </state>
};