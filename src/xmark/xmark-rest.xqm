(:~ 
 : restxq interface for XMark benchmark
 :
 :)
module namespace sr = 'apb.xmark.rest';
declare default function namespace 'apb.xmark.rest'; 
import module namespace xm='apb.xmark.test' at 'xmark.xqm';
import module namespace txq = 'apb.txq' at 'lib.xq/txq.xqm';

(:~
 : xmark application entry point.
 :)
declare 
%rest:GET %rest:path("xmark")
%output:method("html")   
function xmark() {
  let $size:=xm:file-size()
  let $db:=db:exists("xmark")
  return render("main.xq",map{"size":=xm:file-size(),"db":=db:exists("xmark")})
 
};

(:~
 : run xmark
 :)
declare 
%rest:POST %rest:path("xmark/results")
%restxq:form-param("timeout", "{$timeout}","15")  
%output:method("html")   
function xmark-post($timeout) {
    let $res:=( 1 to 20)!xm:time-xmark(.,fn:number($timeout))
    let $avg:=fn:sum($res) div 20
    let $res2:= $res!<div>{.}</div>
    return render("results.xq",map{
    "out":=<div>{$res2}<div>Avg:{$avg}</div></div>})
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
txq:render(fn:resolve-uri("./templates/" || $template)
            ,$map
            ,fn:resolve-uri("./templates/layout.xq")
            )
};