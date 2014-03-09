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
  let $size:="?"
  return 
  <body>
    <form method="post">
    <div>auction file size:{$size}</div>
    <button type="submit" >run XMark</button>
    </form>
    <hr/>
    <div>fn:static-base-uri():{fn:static-base-uri()}</div>
    <div> eval static-base-uri():{xquery:eval("fn:static-base-uri()||'~'")}</div>
    <form method="post" action="xmark/create">
    <input type="number" name="factor" value="0.1"/>
    <button type="submit" >run XMLgen</button>
    </form>
    </body>
};

(:~
 : run xmark
 :)
declare 
%rest:POST %rest:path("xmark")
%output:method("html")   
function xmark-post() {
    let $res:=( 1 to 20)!xm:time-xmark(.,10)
    let $res2:= $res!<div>{.}</div>
    return <div>{$res2}</div>
};

(:~
 : xmark create source file.
 :)
declare 
%rest:POST %rest:path("xmark/create")
%restxq:form-param("factor", "{$factor}","0.1")  
%output:method("html")   
function create($factor) {
 let $go:=xm:create($factor)
 return <div>Not yet: {$factor}</div>
}; 