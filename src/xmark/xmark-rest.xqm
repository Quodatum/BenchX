(:~ 
 : restxq interface for XMark benchmark
 :
 :)
module namespace sr = 'apb.xmark.rest';
declare default function namespace 'apb.xmark.rest'; 
import module namespace xm='apb.xmark.test' at 'xmark.xqm';

(:~
 : xmark application entry point.
 :)
declare 
%rest:GET %rest:path("xmark")
%output:method("html")   
function xmark() {
  let $size:=xm:file-size()
  let $db:=db:exists("xmark")
  return 
  <body>
    <form method="post">
    <div>auction file size:{$size}</div>
    <button type="submit" >run XMark</button>
     <label>Timeout (secs):
    <input type="number" name="timeout" value="15"/>
    </label>
    </form>
    <hr/>
    <div>fn:static-base-uri():{fn:static-base-uri()}</div>
    <div> eval static-base-uri():{xquery:eval("fn:static-base-uri()||'~'")}</div>
    <div> db 'xmark': {$db}</div>
     <div> db 'xmark': {$db}</div>
    <form method="post" action="xmark/xmlgen">
    <label>Factor:
    <input type="number" name="factor" value="0.5"/>
    </label>
   
    <button type="submit" >run XMLgen</button>
    </form>
    
    <form method="post" action="xmark/manage">
    <button type="submit" >create db</button>
    </form>
    </body>
};

(:~
 : run xmark
 :)
declare 
%rest:POST %rest:path("xmark")
%restxq:form-param("timeout", "{$timeout}","15")  
%output:method("html")   
function xmark-post($timeout) {
    let $res:=( 1 to 20)!xm:time-xmark(.,fn:number($timeout))
    let $avg:=fn:sum($res) div 20
    let $res2:= $res!<div>{.}</div>
    return <div>{$res2}<div>Avg:{$avg}</div></div>
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