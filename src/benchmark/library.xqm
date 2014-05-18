(:~ 
 : library handling for benchx
 :
 :)
module namespace lib = 'apb.benchx.library';
declare default function namespace 'apb.benchx.library'; 

(:~
 : get new doc defaults
 :)
declare variable $lib:new as element(benchmark)
             :=db:open("benchmark","benchmark.xml")/benchmark;

(:~
 : get new doc with given id
 :)
declare function id($id) as element(benchmark)
{
  fn:collection("benchmark/library")/benchmark[id=$id]
};

(:~
 : add record to library
 :)
declare %updating function addrecord() 
{
  db:output(<json objects="json"><todo>THIS</todo></json>)
};

(:~
 : list all in library
 :)
declare function list(){
 <json  objects="_" arrays="json ">
   {for $doc in fn:collection("benchmark/library")/benchmark
   order by $doc/meta/created
   return <_>{$doc/id,
    $doc/suite,
    $doc/server/description,
    $doc/meta/description,
    $doc/meta/created
   }</_>
   }</json>
 };
 
 (:~ 
 : Prepare benchmark for json
 : @param b results of a run.
 : @return json style xml for serialization.
:)
declare function json($b as element(benchmark)
)as element(json)
{
<json objects="json benchmark meta server environment run">{
    copy $d:=$b
    modify (for $n in $d//*[@type="array"]/* 
            return replace node $n with <_ type="object">{$n}</_>)
    return $d
}</json>
};