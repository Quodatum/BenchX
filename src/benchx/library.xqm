(:~ 
 : library handling for benchx
 :@author Andy Bunce
 :@version 0.1
 :)
module namespace lib = 'quodatum.benchx.library';
declare default function namespace 'quodatum.benchx.library'; 
declare namespace res="https://github.com/Quodatum/BenchX/results";

(:~
 : get new doc defaults
 :)
declare variable $lib:new as element(res:benchmark)
             :=db:open("benchx","benchmark.xml")/res:benchmark;

declare variable $lib:benchmarks as element(res:benchmark)*
             :=fn:collection("benchx/library")/res:benchmark;
(:~
 : get benchmark doc with given id
 :)
declare function get($id as xs:string) as element(res:benchmark)
{
  let $b:=$lib:benchmarks[res:id=$id] (:@TODO use name? :)
  return if($b) then $b else fn:error((),"Bad id")
};

declare function exists($id as xs:string) as xs:boolean
{
  $lib:benchmarks[res:id=$id] (:@TODO use name? :)
};
(:~
 : add session data to library
 : @param $data json has title used for description
 : @param $session has benchmark element
 :)
declare %updating function add-session(
                $data,
                $session as element(res:benchmark)
){
    let $data:=fn:trace($data,"ADD ")
    let $desc:=$data/json/title/fn:string()
    let $suite:=$data/json/suite/fn:string()
    let $id:=random:uuid()
    let $new:=copy $d:=$session
            modify (
            replace value of node $d/res:id with $id,
            replace value of node $d/res:suite with $suite,
            replace value of node $d/res:meta/res:created with fn:current-dateTime(),
            replace value of node $d/res:meta/res:description with $desc
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
declare %updating function store($results as element(res:benchmark))
{
    let $id:=$results/res:id/fn:string()
    return db:replace("benchx", "library/" || $id || ".xml" ,$results)
};

(:~
 : delete id from library
 :)
declare %updating function delete($id as xs:string)
{
    db:delete("benchx", "library/" || $id || ".xml" )
};

(:~
 : get id from XML
 :)
declare function id($results as element(res:benchmark)) as xs:string{
    $results/res:id/fn:string()
};
(:~
 : list all in library
 :)
declare function list($suite){
let $items:=$lib:benchmarks
let $items:=if($suite) then $items[res:suite=$suite] else $items
return <json  objects="_" arrays="json ">
   {for $doc in $items
   order by $doc/res:meta/res:created descending
   return <_>{$doc/res:id,
    $doc/res:suite,
    $doc/res:environment/res:basex.version,
    $doc/res:server/res:description,
    $doc/res:meta/res:description,
    $doc/res:meta/res:created,
    $doc/res:environment/res:os.name,
    $doc/res:environment/res:os.arch,
    $doc/res:environment/res:java.version,
    $doc/res:server/res:hostname,
    <runs type="number">{fn:count($doc/res:runs/res:run)}</runs>
   }</_>
   }</json>
 };

 

(:~
 : environment from  benchmark
 :)
 declare function environment($benchmark as element(res:benchmark)) 
 as element(_)*{
     <_ type="object">{
     $benchmark/res:environment/*[fn:not(self::res:runtime.freeMemory 
                                    | self::res:runtime.totalMemory
                                    | self::res:runtime.maxMemory)]
     }</_>
 };
 
(:~
 : unique environments from  docs
 :)
 declare function environments() 
 as element(_)*{
 fn:fold-left($lib:benchmarks,
              (),
               function($seq,$item){
                      let $env:=lib:environment($item)
                      return if(some $e in $seq satisfies fn:deep-equal($e,$env)) 
                             then $seq 
                             else ($env,$seq)
              }
              )
 };