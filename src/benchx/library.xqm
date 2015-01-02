(:~ 
 : library handling for benchx
 :@author Andy Bunce
 :@version 0.1
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
 : get doc with given id
 :)
declare function id($id) as element(benchmark)
{
  $lib:benchmarks[id=$id]
};

(:~
 : add session data to library
 : @param $data json has title used for description
 : @param $session has benchmark element
 :)
declare %updating function add-session(
                $data,
                $session as element(benchmark)
){
    let $data:=fn:trace($data,"ADD ")
    let $desc:=$data/json/title/fn:string()
    let $id:=random:uuid()
    let $new:=copy $d:=$session
            modify (
            replace value of node $d/id with $id,
            replace value of node $d/meta/created with fn:current-dateTime(),
            replace value of node $d/meta/description with $desc
                 )
            return $d
          
    return (
            store($new), 
            db:output(<json objects="json"><id>{$id}</id></json>)
            )
};

(:~
 : store in library
 :)
declare %updating function store($results as element(benchmark))
{
    let $id:=$results/id/fn:string()
    return db:replace("benchx", "library/" || $id || ".xml" ,$results)
};

(:~
 : list all in library
 :)
declare function list($suite){
let $items:=$lib:benchmarks
let $items:=if($suite) then $items[suite=$suite] else $items
return <json  objects="_" arrays="json ">
   {for $doc in $items
   order by $doc/meta/created descending
   return <_>{$doc/id,
    $doc/suite,
    $doc/environment/basex.version,
    $doc/server/description,
    $doc/meta/description,
    $doc/meta/created,
    $doc/environment/os.name,
    $doc/environment/os.arch,
    $doc/environment/java.version,
    $doc/server/hostname
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
<json objects="json benchmark meta server environment ">{
    copy $d:=$b
    modify (for $n in $d//*[@type="array"]/* 
            return replace node $n with <_ type="object">{$n/*}</_>,
            delete node $d//comment()
            )
    return $d
}</json>
};