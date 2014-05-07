(:~ 
 : restxq interface for XMark benchmark
 :
 :)
module namespace sr = 'apb.benchmark.rest';
declare default function namespace 'apb.benchmark.rest'; 
import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace dbtools = 'apb.dbtools' at 'lib.xq/dbtools.xqm';
import module namespace env = 'apb.basex.env' at 'lib.xq/basex-env.xqm';

(:~
 : xmark application entry point.
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

declare 
%rest:POST("{$body}") %rest:path("benchmark/execute")
%output:method("json")   
function execute($body)
{
let $name:=$body/json/name/fn:string()
let $time:=xm:time-xmark($name,10)
 return <json objects="json">
  <name>{$name}</name>
  <runtime type="number">{$time}</runtime>
  <mode>{xm:mode()}</mode>
  <created>{fn:current-dateTime()}</created>
  </json>
};


(:~
 : xmark create source file.
 : note this switches to file mode
 :)
declare %updating
%rest:POST %rest:path("benchmark/xmlgen")
%restxq:form-param("factor", "{$factor}",0)  
%output:method("json")   
function xmlgen($factor) {
 let $go:=xm:xmlgen($factor)
 return (xm:manage-db(fn:false())
        ,db:output(status()))
}; 

(:~
 : xmark create db
 :)
declare %updating
%rest:POST %rest:path("benchmark/manage")
%output:method("json")   
function create() {
try{
 (xm:toggle-db(),
 db:output(status()))
 }catch * {
 db:output("Error")
 }
}; 

(:~
 : xmark create db
 :)
declare 
%rest:GET %rest:path("benchmark/status")
%output:method("json")   
function status() {
<json objects="json _ state" >
    <state>
        <version>{env:basex-version()}</version>
        <mode>{xm:mode()}</mode>
        <size>{prof:human(xm:file-size())}</size>
    </state>
</json>
}; 

declare 
%rest:GET %rest:path("benchmark/queries")
%output:method("json")   
function queries() {
<json objects="json _ " arrays="queries runs">
    <queries>{ for  $file in xm:list-tests("queries")
            return <_>
                <name>{$file}</name>
                <src>{xm:get-xmark($file)}</src>
                <runs/>
                </_>
    }</queries>
</json>
}; 

declare 
%rest:GET %rest:path("benchmark/environment")
%output:method("json")   
function env() {
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

