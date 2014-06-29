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
%output:method("text")  
function error($description) {
    (web:status(500,"Server error "),$description)
};


(:~
 : Execute one test
 : @param name the test to run
 : @param time
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
%restxq:form-param("mode", "{$mode}")
%restxq:form-param("factor", "{$factor}")
%output:method("json")   
function state-post($mode,$factor as xs:double) 
{
    (: @TODO o/p new rather than current state :)
    (db:output(<json objects="json state">{s:state()}</json>),
     s:make($mode,$factor))
}; 

(:~
 : clear any session state
 :)
declare 
%rest:DELETE %rest:path("benchx/api/state")
%output:method("json")   
function state-delete() 
{
 s:clear()
}; 

(:~
 : list of library files
 :)
declare 
%rest:GET %rest:path("benchx/api/library")
%output:method("json")   
function library() 
{
    lib:list()
}; 

(:~
 : post new record
 :)
declare %updating
%rest:POST("{$body}") %rest:path("benchx/api/library")
%output:method("json")   
function addrecord($body) 
{
    lib:add-session($body,s:benchmark())  
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
    let $b:=lib:id($id)
    return if($format="json") then lib:json($b)
            else (web:download-response("xml",$id || ".xml"),$b) 
};

(:~
 : delete record
 :)
declare 
%rest:DELETE %rest:path("benchx/api/library/{$id}")
%restxq:form-param("password", "{$password}")
%output:method("json")   
function record-delete($id,$password) 
{
    <json objects="json">
    <todo>password: {$password}</todo>
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
    return <json arrays="json queries">{
    for $suite in $suites
    let $desc:=xm:describe( $suite)
    return <_ type="object">
            <name>{$suite}</name>
            <href>#/suite/{$suite}</href>
            <describe>{$desc}</describe>
            <session>#/suite/{$suite}/session</session>
            <library>#/suite/{$suite}/library</library>
            <results>?</results>
            <queries>{ for  $file in xm:queries( $suite )
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
%rest:GET %rest:path("benchx/api/environment")
%output:method("json")  
function env() 
{
<json type="object" >
    {env:xml()/*}
</json>
}; 

