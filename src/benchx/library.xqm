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
             :=db:open("benchx","benchmark.xml")/benchmark;

declare variable $lib:benchmarks as element(benchmark)*
             :=fn:collection("benchx/library")/benchmark;
(:~
 : get new doc with given id
 :)
declare function id($id) as element(benchmark)
{
  $lib:benchmarks[id=$id]
};

(:~
 : add record to library
 :)
declare %updating function add-record($data) 
{
    let $data:=fn:trace($data,"ADD ")
    let $desc:=$data/json/description/fn:string()
    let $id:=random:uuid()
    let $new:=copy $d:=$lib:new
            modify (
            replace value of node $d/id with $id,
            replace value of node $d/meta/created with fn:current-dateTime(),
            replace value of node $d/meta/description with $desc
            )
            return $d
          
    
    return (
            db:replace("benchx", "library/" || $id || ".xml" ,$new), 
            db:output(<json objects="json"><todo>{$id}</todo></json>)
            )
};

(:~
 : list all in library
 :)
declare function list(){
 <json  objects="_" arrays="json ">
   {for $doc in $lib:benchmarks
   order by $doc/meta/created descending
   return <_>{$doc/id,
    $doc/suite,
    $doc/server/description,
    $doc/meta/description,
    $doc/meta/created,
    $doc/environment/os.arch
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