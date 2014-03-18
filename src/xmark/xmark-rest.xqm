(:~ 
 : restxq interface for XMark benchmark
 :
 :)
module namespace sr = 'apb.xmark.rest';
declare default function namespace 'apb.xmark.rest'; 
import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace txq = 'apb.txq' at 'lib.xq/txq.xqm';
import module namespace env = 'apb.basex.env' at 'lib.xq/basex-env.xqm';
import module namespace bootstrap = 'apb.basex.bootstrap' at 'lib.xq/bootstrap.xqm';

(:~
 : xmark application entry point.
 :)
declare 
%rest:GET %rest:path("xmark")
%output:method("html")   
function xmark() {
  let $props:=env:about()
  let $keys:=for $k in map:keys($props) order by $k return $k
  let $props:=bootstrap:property-table($keys,map:get($props,?))
  let $map:=map{"env":=bootstrap:panel("Environment Java Properties",$props)}
  return render("main.xq",$map)
 
};

(:~
 : run xmark
 :)
declare 
%rest:POST %rest:path("xmark/results")
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
 : UI xmark create source file.
 :)
declare 
%rest:GET %rest:path("xmark/xmlgen")
%output:method("html")   
function xmlgen-get() {
 render("xmlgen.xq",map{})
}; 
(:~
 : xmark create source file.
 :)
declare %updating
%rest:POST %rest:path("xmark/xmlgen")
%restxq:form-param("factor", "{$factor}","0.5")  
%output:method("html")   
function xmlgen($factor) {
 let $go:=xm:xmlgen($factor)
 return (xm:manage-db(fn:false())
        ,db:output(<rest:redirect>/xmark</rest:redirect>))
}; 

(:~
 : xmark create db
 :)
declare %updating
%rest:POST %rest:path("xmark/manage")
%output:method("html")   
function create() {
try{
 (xm:toggle-db(),
 db:output(<rest:redirect>/xmark</rest:redirect>))
 }catch * {
 db:output("Error")
 }
}; 

(:~
 : xmark create db
 :)
declare 
%rest:GET %rest:path("xmark/script")
%output:method("text")   
function script() {
 <rest:response>
    <output:serialization-parameters>
      <output:media-type value='text/javascript'/>
    </output:serialization-parameters>
  </rest:response>,
 fn:unparsed-text("templates/app.js")
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
