(:~ 
 : A RESTXQ interface for running benchmarks against BaseX
 :@author Andy Bunce
 :@version 0.1
 :)
module namespace bm = 'apb.benchx.rest';
declare default function namespace 'apb.benchx.rest'; 
declare namespace res="https://github.com/Quodatum/BenchX/results";

import module namespace s='apb.benchx.state' at 'state.xqm';
import module namespace lib='quodatum.benchx.library' at 'library.xqm';
import module namespace suite='apb.benchx.suite' at 'suite.xqm';

import module namespace dbtools = 'apb.dbtools' at 'lib.xq/dbtools.xqm';
import module namespace env = 'quodatum.basex.env' at 'lib.xq/basex-env.xqm';

import module namespace txq = 'quodatum.txq' at "lib.xq/txq.xqm";
import module namespace dice = 'quodatum.web.dice/v2' at "lib.xq/dice.xqm";
import module namespace web = 'quodatum.web.utils3' at 'lib.xq/webutils.xqm';


(:~
 : Benchmark html application entry point.
 : Will create db if required
 :)
declare %updating
%rest:GET %rest:path("benchx")
%output:method("html")   
function benchmark()
{
    if(fn:not(env:basex-minversion("8.0"))) then      
            db:output(
            (web:status(500,"Server error")," BaseX min ver 8.0 required")
            )
    else
        (s:init(),
        if(db:exists("benchx")) then ()
        else 
            dbtools:sync-from-path("benchx",fn:resolve-uri("data/benchx"))
            ,
            db:output(render("main.xq",map{}))
         )
};


declare %rest:error("*")
%rest:error-param("description", "{$description}")
%rest:error-param("additional","{$additional}") (: error stack trace  :)
%output:method("text")  
function error($description,$additional) {
    (web:status(500,"Benchx Server error: "),$additional)
};

(:~
 : run xmark query
 :)
declare function time-xmark(
  $xq as xs:string,
  $timeout as xs:double)
 {
  let $xq:= 'declare base-uri "' || fn:static-base-uri() ||'";&#10;' || $xq 
 
  let $res:= time($xq,$timeout)
  return (<runtime type="number">{$res[1]}</runtime>,
         <status>{$res[2]}</status>)
};


(:~
 : @param $xq xquery to evaluate 
 : @param $timeout stop execution after this time in seconds
 : @return two item sequence(execution time of $xq ,error code or "")
 :) 
declare function time($xq as xs:string,$timeout as xs:double)
as item()*{
 let $bindings:=map{}
 let $opts:=map {
     "permission" : "create",
     "timeout": $timeout
  }
  return try{
       let $t1:=prof:current-ms()
       let $x:= xquery:eval($xq,$bindings,$opts)
       let $t:=(prof:current-ms()-$t1) div 1000
       return ($t,"")
      }catch * 
      {
        ($timeout ,$err:code)
      }
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
let $xq:=suite:get-query($suite || "/" || $name)
let $time:=time-xmark($xq,s:timeout())
let $run:= <run>
        {$time}
        <name>{$name}</name>
        <mode>{s:mode()}</mode>
        <factor>{$s:root/state/factor/fn:string()}</factor>
        <created>{fn:current-dateTime()}</created>
    </run>
 return (db:output(web:fixup($run)),s:add($run))
};


(:~
 : get information about application state
 :)
declare 
%rest:GET %rest:path("benchx/api/state")
%output:method("json")   
function state() 
{
    s:state()=>web:fixup()
}; 

(:~
 : set application state mode and factor
 :)
declare %updating
%rest:POST %rest:path("benchx/api/state")
%restxq:query-param("mode", "{$mode}","D")
%restxq:query-param("factor", "{$factor}")
%restxq:query-param("generator", "{$generator}","xmlgen")
%output:method("json")   
function state-post($mode,
                    $factor as xs:double,
                    $generator) 
{
    (: @TODO o/p new rather than current state :)
    let $factor:=fn:trace($factor,"factor:")
    return (
        s:state()=>web:fixup()=>db:output(),
        s:make($mode,$factor,$generator)
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
%restxq:query-param("format", "{$format}","json")
%output:method("json")   
function library($suite,$format) 
{
    if($format="json") then 
        lib:list($suite) 
    else 
        let $a:=lib:collection()
        let $zip:= archive:create($a!db:path(.),$a!fn:serialize(.))
        return web:zip-download("library.zip",$zip)
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
    return if($format="json") then web:fixup(<json>{$b}</json>)
            else (web:method("xml"),$b) 
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
    let $suite as xs:string:=$lib:benchmarks[res:id=$id]/res:suite/fn:string()
	let $hits:=$lib:benchmarks[res:suite=$suite]/res:runs/res:run[
                     res:name=$query and
                    (res:mode || res:factor)=$state
                ]
    let $_:=<json objects="json _">
                <total type="number">{fn:count($hits)}</total>
                <id>{$id}</id>
                <suite>{$suite}</suite>
                <query>{$query}</query>
                <hit type="array">
                    {for $hit in $hits
                    let $b:=$hit/ancestor::res:benchmark
					order by fn:number($hit/res:runtime)
                    return <_>{        
                    $hit/res:runtime,
					$b/res:server/res:hostname,
					$b/res:meta/res:description,
                    $b/res:id
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
    let $suites:=suite:list()
    return <json type="array">{
    for $suite in $suites
    let $desc:=suite:describe( $suite)
    return <_ type="object">
            <name>{$suite}</name>
            <href>#/suite/{$suite}</href>
            <describe>{$desc}</describe>
            <session>#/suite/{$suite}/session</session>
            <library>#/suite/{$suite}/library</library>
            <results type="number">{fn:count($lib:benchmarks[res:suite=$suite])}</results>
            <queries type="array">{ for  $file in suite:queries( $suite )
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
    { for  $file in suite:queries( $suite )
            return <_>
                <name>{$file}</name>
                <src>{suite:get-query($suite || "/" || $file)}</src>
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
 : validate the library. @TODO
 : @return json env array
 :)
declare 
%rest:GET %rest:path("benchx/api/validate")
%output:method("json")  
function validate() 
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
  </docs></json>    
}; 

(:~
 : html rendering
 :) 
declare function render($template,$map){
    let $defaults:=map{
                        "version":"0.8.4",
                        "static":"/static/benchx/"
                    }
    let $map:=map:merge(($map,$defaults))
    return (web:method("html"),txq:render(
                fn:resolve-uri("./templates/" || $template)
                ,$map
                ,fn:resolve-uri("./templates/layout.xq")
                )
            )
};

