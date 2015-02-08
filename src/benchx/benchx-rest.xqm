(:~ 
 : A RESTXQ interface for running benchmarks against BaseX
 :@author Andy Bunce
 :@version 0.1
 :)
module namespace bm = 'apb.benchx.rest';
declare default function namespace 'apb.benchx.rest'; 

import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace s='apb.benchx.state' at 'state.xqm';
import module namespace lib='apb.benchx.library' at 'library.xqm';

import module namespace dbtools = 'apb.dbtools' at 'lib.xq/dbtools.xqm';
import module namespace env = 'quodatum.basex.env' at 'lib.xq/basex-env.xqm';
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
%rest:GET %rest:path("benchx")
%output:method("html")   
function benchmark()
{
    if(fn:not(env:basex-minversion("7.8.2"))) then      
            db:output(
            (web:status(500,"Server error")," BaseX min ver 7.8.2 required")
            )
    else
        (s:init(),
        if(db:exists("benchx")) then ()
        else 
            dbtools:sync-from-path("benchx",fn:resolve-uri("data/benchx"))
            ,
            db:output(<rest:forward>/static/benchx</rest:forward>)
         )
};


declare %rest:error("*")
%rest:error-param("description", "{$description}")
%rest:error-param("additional","{$additional}") (: error stack trace  :)
%output:method("text")  
function error($description,$additional) {
    (web:status(500,"Server error $%^%£$ "),$additional)
};


(:~
 : Execute one test and store to session
 : @param body name and suite
 : @return information about the result, including runtime
 :)
declare %updating
%rest:POST("{$body}") %rest:path("benchx/api/execute")
%output:method("json")   
function execute($body)
{
let $name:=$body/json/name/fn:string()
let $suite:=$body/json/suite/fn:string()
let $time:=xm:time-xmark($suite || "/" || $name,$bm:timeout)
let $run:= <run>
        {$time}
        <name>{$name}</name>
        <mode>{s:mode()}</mode>
        <factor>{$s:root/state/factor/fn:string()}</factor>
        <created>{fn:current-dateTime()}</created>
    </run>
 return db:output((<json objects="json run">{$run}</json>,
        s:add($run)))
};


(:~
 : get information about application state
 :)
declare 
%rest:GET %rest:path("benchx/api/state")
%output:method("json")   
function state() 
{
<json objects="json _ state" >
    {s:state()}
</json>
}; 

(:~
 : set application state mode and factor
 :)
declare %updating
%rest:POST %rest:path("benchx/api/state")
%restxq:query-param("mode", "{$mode}","D")
%restxq:query-param("factor", "{$factor}")
%output:method("json")   
function state-post($mode,$factor as xs:double) 
{
    (: @TODO o/p new rather than current state :)
    let $factor:=fn:trace($factor,"factor:")
    return (
        db:output(<json objects="json state">{s:state()}</json>),
        s:make($mode,$factor)
     )
}; 



(:~
 : save session timing data as a new library file
 :)
declare %updating
%rest:POST("{$body}") %rest:path("benchx/api/session")
%output:method("json")   
function addrecord($body) 
{
    lib:add-session($body,s:benchmark())  
};

(:~
 : clear any session timing data
 :)
declare 
%rest:DELETE %rest:path("benchx/api/session")
%output:method("json")   
function session-delete() 
{
 s:clear()
}; 

(:~
 : list of library files
 :)
declare 
%rest:GET %rest:path("benchx/api/library")
%restxq:query-param("suite", "{$suite}")
%output:method("json")   
function library($suite) 
{
    lib:list($suite)
}; 

(:~
 : get record as json (default) or xml
 :)
declare 
%rest:GET %rest:path("benchx/api/library/{$id}")
%restxq:query-param("format", "{$format}","json")
%output:method("json")
function record($id,$format) 
{
    let $b:=lib:get($id)
    return if($format="json") then lib:json($b)
            else (web:download-response("xml",$id || ".xml"),$b) 
};

(:~
 : get compare data for state like D0
 :)
declare 
%rest:GET %rest:path("benchx/api/library/{$id}/compare")
%restxq:query-param("format", "{$format}","json")
%restxq:query-param("query", "{$query}","")
%restxq:query-param("state", "{$state}","")
%output:method("json")
function compare($id,$query,$state,$format) 
{
    let $suite as xs:string:=$lib:benchmarks[id=$id]/suite/fn:string()
	let $hits:=$lib:benchmarks[suite=$suite]/runs/run[
                     name=$query and
                    (mode || factor)=$state
                ]
    let $_:=<json objects="json _">
                <total type="number">{fn:count($hits)}</total>
                <id>{$id}</id>
                <suite>{$suite}</suite>
                <query>{$query}</query>
                <hit type="array">
                    {for $hit in $hits
                    let $b:=$hit/ancestor::benchmark
					order by fn:number($hit/runtime)
                    return <_>{        
                    $hit/runtime,
					$b/server/hostname,
					$b/meta/description,
                    $b/id
                    }
                    </_>
                    }
                </hit>
            </json> 
    return $_
};

(:~
 : delete record
 :)
declare %updating
%rest:DELETE %rest:path("benchx/api/library/{$id}")
%restxq:form-param("password", "{$password}")
%output:method("json")   
function record-delete($id as xs:string,$password) 
{
   (db:output( <json objects="json">
    <todo>password: {$password}</todo>
    </json>),lib:delete($id) )
};
 
 
(:~
 : list of suites
 : @return array of suite names
 :)
declare 
%rest:GET %rest:path("benchx/api/suite")
%output:method("json")   
function suites() 
{
    let $suites:=xm:list-suites()
    return <json type="array">{
    for $suite in $suites
    let $desc:=xm:describe( $suite)
    return <_ type="object">
            <name>{$suite}</name>
            <href>#/suite/{$suite}</href>
            <describe>{$desc}</describe>
            <session>#/suite/{$suite}/session</session>
            <library>#/suite/{$suite}/library</library>
            <results type="number">{fn:count($lib:benchmarks[suite=$suite])}</results>
            <queries type="array">{ for  $file in xm:queries( $suite )
                    return <_>{$file}</_>
            }</queries>
            </_>
            }
</json>
};

(:~
 : Get list of tests in suite
 : @param suite name of suite
 : @return the suite object
 :)
declare 
%rest:GET %rest:path("benchx/api/suite/{$suite}")
%output:method("json")   
function queries($suite as xs:string) 
{
<json objects="json _" arrays="queries runs">
    <name>{$suite}</name>
     <session>#/suite/{$suite}/session</session>
    <library>#/suite/{$suite}/library</library>
    <queries>
    { for  $file in xm:queries( $suite )
            return <_>
                <name>{$file}</name>
                <src>{xm:get-xmark($suite || "/" || $file)}</src>
                <runs />
                </_>
    }
    </queries>
</json>
};  

(:~
 : Information about the server platform, Java version etc.
 : @return json env array
 :)
declare 
%rest:GET %rest:path("benchx/api/thisenv")
%output:method("json")  
function about() 
{
<json type="object" >
    {env:xml()/*}
</json>
}; 

(:~
 : distinct environments from the library.
 : @return json env array
 :)
declare 
%rest:GET %rest:path("benchx/api/environment")
%output:method("json")  
function env() 
{
<json type="array" >   
    {lib:environments()}
</json>
}; 
(:~
 : testbed not part of app, use this for experiments
 :)
declare 
%rest:GET %rest:path("benchx/api/~testbed")
%output:method("json")   
function testbed() 
{
   <json  objects="json doc _" arrays="docs ">
   <docs>
   {for $doc in $lib:benchmarks
   order by $doc/meta/created
   return <_>
   {$doc/id,
    $doc/server/suite,
    $doc/server/description,
    $doc/meta/description,
    $doc/meta/created
       }</_>
   }</docs></json>    
}; 

