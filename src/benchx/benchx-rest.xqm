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
 : Generate auction.xml source file using xmlgen.
 : note this switches to file mode
 : @param xmlgen factor size for file to create
 :)
declare %updating
%rest:POST %rest:path("benchx/api/xmlgen")
%restxq:form-param("factor", "{$factor}",0)  
%output:method("json")   
function xmlgen($factor)
{
 let $go:=xm:xmlgen($factor)
 return (s:set-mode("F"),
        s:set-factor($factor),
        db:output(status()))
}; 

(:~
 : Create database from file
 :)
declare %updating
%rest:POST %rest:path("benchx/api/manage")
%output:method("json")   
function create()
{
try{
 (s:toggle-db(),
 db:output(status()))
 }catch * {
 db:output(web:status(500,$err:description))
 }
}; 

(:~
 : get information about application state
 :)
declare 
%rest:GET %rest:path("benchx/api/status")
%output:method("json")   
function status() 
{
<json objects="json _ state" >
    {s:state()}
</json>
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
 : get record
 :)
declare 
%rest:GET %rest:path("benchx/api/library/{$id}")
%output:method("json")   
function record($id) 
{
    lib:json(lib:id($id))  
};

 
(:~
 : testbed not part of app, use this for experiments
 :)
declare 
%rest:GET %rest:path("benchx/api/testbed")
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
    let $suites:=("xmark","apb")
    return <json objects="_" arrays="json">{
    for $s in $suites
    return <_>
    <name>{$s}</name>
    <href>#/suite/{$s}</href>
    </_>
    }
</json>
};

(:~
 : Get list of tests in suite
 : @param suite name of suite
 : @return array of tests in suite
 :)
declare 
%rest:GET %rest:path("benchx/api/suite/{$suite}")
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
%rest:GET %rest:path("benchx/api/environment")
%output:method("json")   
function env() 
{
<json objects="json environment " >
    {env:xml()}
</json>
}; 




(:~
 : show xqdoc for rest api
 :)
declare 
%rest:GET %rest:path("benchx/doc/xqdoc")
%output:method("html")  
function xqdoc() 
{
    doc:generate-html(fn:static-base-uri())
};
 
(:~
 : show xqdoc for rest api
 :)
declare 
%rest:GET %rest:path("benchx/doc/wadl")
%output:method("html")  
function wadl() 
{
  doc:wadl("/benchx") 
}; 
