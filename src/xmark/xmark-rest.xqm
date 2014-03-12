(:~ 
 : restxq interface for XMark benchmark
 :
 :)
module namespace sr = 'apb.xmark.rest';
declare default function namespace 'apb.xmark.rest'; 
import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace txq = 'apb.txq' at 'lib.xq/txq.xqm';
import module namespace env = 'apb.basex.env' at 'lib.xq/basex-env.xqm';

(:~
 : xmark application entry point.
 :)
declare 
%rest:GET %rest:path("xmark")
%output:method("html")   
function xmark() {
  let $size:=xm:file-size()
  let $db:=db:exists("xmark")
  let $map:=map{"size":=xm:file-size()
                ,"db":=db:exists("xmark")
                ,"env":=props()}
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
    let $res:=( 1 to 20)!xm:time-xmark(.,fn:number($timeout))
    let $avg:=fn:sum($res) div 20
    let $res2:= $res!<tr><td >{fn:position()}</td>
                        <td><span class="pull-right">{.}</span></td> 
                    </tr>
    return render("results.xq",map{
    "out":=(<div class="col-xs-2"><table class="table table-striped">
                    <tbody>{$res2}</tbody>
                </table></div>
            ,<div>Avg:{$avg}</div>)})
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
 (xm:manage-db(fn:true()),
 db:output(<rest:redirect>/xmark</rest:redirect>))
}; 

declare function render($template,$map){
let $defaults:=map{"version":=env:basex-version()}
let $map:=map:new(($map,$defaults))
return txq:render(
            fn:resolve-uri("./templates/" || $template)
            ,$map
            ,fn:resolve-uri("./templates/layout.xq")
            )
};

declare function props(){
<table class="table table-striped">
<thead><tr><th>Name</th><th>Value</th></tr></thead>
<tbody>
{for $p in $env:core return <tr><td>{$p}</td>
                                <td>{env:getProperty($p)}</td>
                             </tr>}
</tbody>
</table>
};