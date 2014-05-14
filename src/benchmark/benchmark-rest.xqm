(:~ 
 : A RESTXQ interface for running benchmarks against BaseX
 :@author Andy Bunce
 :@version 0.1
 :)
module namespace bm = 'apb.benchmark.rest';
declare default function namespace 'apb.benchmark.rest'; 

import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace s='apb.benchmark.state' at 'state.xqm';

import module namespace dbtools = 'apb.dbtools' at 'lib.xq/dbtools.xqm';
import module namespace env = 'apb.basex.env' at 'lib.xq/basex-env.xqm';
import module namespace doc = 'apb.doc' at 'lib.xq/doctools.xqm';
import module namespace web = 'apb.web.utils3' at 'lib.xq/webutils.xqm';

(:~
 : max time for execution of query
 :)
declare variable $bm:timeout as xs:integer:=10;

(:~
 : Benchmark html application entry point.
 : Will create db if required
 :)
declare %updating
%rest:GET %rest:path("benchmark")
%output:method("html")   
function benchmark()
{(
    if(db:exists("benchmark")) then ()
    else dbtools:sync-from-path("benchmark",fn:resolve-uri("data/benchmark")),
    
    db:output(<rest:forward>/static/benchmark</rest:forward>)
)};

declare %rest:error("*")
%rest:error-param("description", "{$description}") 
%output:method("text")  
function error($description) {
    (web:status(500,"Server error"),$description)
};

(:~
 : Execute one test
 : @param name the test to run
 : @param time
 :)
declare 
%rest:POST("{$body}") %rest:path("benchmark/api/execute")
%output:method("json")   
function execute($body)
{
let $name:=$body/json/name/fn:string()
let $suite:=$body/json/suite/fn:string()
let $time:=xm:time-xmark($suite || "/" || $name,$bm:timeout)
let $run:= <run>
        <name>{$name}</name>
        <runtime type="number">{$time}</runtime>
        <mode>{xm:mode()}</mode>
        <factor>{$xm:factor/fn:string()}</factor>
        <created>{fn:current-dateTime()}</created>
    </run>
 return (<json objects="json run">{$run}</json>,
        s:add($run))
};


(:~
 : xmark create source file.
 : note this switches to file mode
 : @param xmlgen factor size for file to create
 :)
declare %updating
%rest:POST %rest:path("benchmark/api/xmlgen")
%restxq:form-param("factor", "{$factor}",0)  
%output:method("json")   
function xmlgen($factor)
{
 let $go:=xm:xmlgen($factor)
 return (xm:manage-db(fn:false()),
        replace value of node $xm:factor with $factor,
        db:output(status()))
}; 

(:~
 : xmark create db from file
 :)
declare %updating
%rest:POST %rest:path("benchmark/api/manage")
%output:method("json")   
function create()
{
try{
 (xm:toggle-db(),
 db:output(status()))
 }catch * {
 db:output(web:status(500,$err:description))
 }
}; 

(:~
 : get information about application state
 :)
declare 
%rest:GET %rest:path("benchmark/api/status")
%output:method("json")   
function status() 
{
<json objects="json _ state" >
    {s:state()}
</json>
}; 

(:~
 : get information about library file
 :)
declare 
%rest:GET %rest:path("benchmark/api/library")
%output:method("json")   
function library() 
{
    json(xm:doc("6b534f9a-798f-4a4f-aef2-11db7b024912")/benchmark)
}; 

(:~
 : get information about library file
 :)
declare 
%rest:GET %rest:path("benchmark/api/ben")
%output:method("json")   
function ben() 
{
    json(s:benchmark())
}; 
(:~
 : @return list of tests in suite
 :)
declare 
%rest:GET %rest:path("benchmark/api/suite/{$suite}")
%output:method("json")   
function queries($suite as xs:string) 
{
<json objects="_" arrays="json runs">
    { for  $file in xm:list-tests( $suite )
            return <_>
                <name>{$file}</name>
                <src>{xm:get-xmark($suite || "/" || $file)}</src>
                <runs />
                </_>
    }
</json>
}; 

(:~
 : Information about the server platform, Java version etc.
 : @return json env array
 :)
declare 
%rest:GET %rest:path("benchmark/api/environment")
%output:method("json")   
function env() 
{
let $map:=env:about()
return <json objects="json _ " arrays="env">
    <env>{ for  $key in map:keys($map)
           order by $key
           return <_>
                <name>{$key}</name>
                <value>{$map($key)}</value>
                </_>
    }</env>
</json>
}; 

(:~
 : show xqdoc for rest api
 :)
declare 
%rest:GET %rest:path("benchmark/api/xqdoc")  
function xqdoc() 
{
    doc:generate-html(fn:static-base-uri())
};
 
(:~
 : show xqdoc for rest api
 :)
declare 
%rest:GET %rest:path("benchmark/api/wadl")  
function wadl() 
{
  doc:wadl("/benchmark") 
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

