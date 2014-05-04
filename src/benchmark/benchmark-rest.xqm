(:~ 
 : restxq interface for XMark benchmark
 :
 :)
module namespace sr = 'apb.benchmark.rest';
declare default function namespace 'apb.benchmark.rest'; 
import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace txq = 'apb.txq' at 'lib.xq/txq.xqm';
import module namespace env = 'apb.basex.env' at 'lib.xq/basex-env.xqm';
import module namespace bootstrap = 'apb.basex.bootstrap' at 'lib.xq/bootstrap.xqm';

(:~
 : xmark application entry point.
 :)
declare %updating
%rest:GET %rest:path("benchmark")
%output:method("html")   
function benchmark() {
(
    if(db:exists("benchmark")) then ()else db:create("benchmark"),
    db:output(<rest:forward>/static/benchmark</rest:forward>)
) 
};

declare 
%rest:POST("{$body}") %rest:path("benchmark/execute")
%output:method("json")   
function execute($body) {
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
 : run xmark
 :)
declare 
%rest:POST %rest:path("benchmark/results")
%restxq:form-param("timeout", "{$timeout}","15")
%restxq:form-param("repeat", "{$repeat}","1")   
%output:method("html")   
function xmark-post($timeout,$repeat) {
    let $files:=xm:list-tests("queries")
    let $res:=$files!xm:time-xmark(.,fn:number($timeout))
 
    return render("results.xq",map{
     "avg":=fn:sum($res) div 20,
     "results":= $res!<td><span class="pull-right">{.}</span></td>,
     "sources":= $files!<th >
                <a href="#" class="pull-right" title="{xm:get-xmark(.)}">{fn:substring-before(.,".")}</a>
                </th> 
     })
};


(:~
 : xmark create source file.
 : note this switches to file mode
 :)
declare %updating
%rest:POST %rest:path("benchmark/xmlgen")
%restxq:form-param("factor", "{$factor}","0.5")  
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
                <runs/>
                </_>
    }</queries>
</json>
}; 


declare function render($template,$map){
  let $defaults:=map{
                 "size":=prof:human(xm:file-size())
                ,"mode":=if(db:exists("xmark"))then "Database" else "File"
                ,"version":=env:basex-version()
                ,"error":=""}
let $map:=map:new(($map,$defaults))
return txq:render(
            fn:resolve-uri("./templates/" || $template)
            ,$map
            ,fn:resolve-uri("./templates/layout.xq")
            )
};
